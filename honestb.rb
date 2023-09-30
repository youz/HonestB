#!/usr/bin/env ruby

class HonestB

  class Expr
    # https://sange.fi/esoteric/essie2/download/lazy-k/lazy.cpp を移植

    attr_accessor :type, :arg1, :arg2

    def initialize(t, a1 = nil, a2 = nil)
      @type = t
      @arg1 = a1
      @arg2 = a2
    end

    S = Expr.new(:S)
    K = Expr.new(:K)
    I = Expr.new(:I)
    FALSE = Expr.new(:FALSE)
    INC = Expr.new(:INC)
    NUM0 = Expr.new(:NUM, 0)

    def drop_i1
      cur = self
      if @type == :I1
        cur = cur.arg1 while cur.type == :I1
        @arg1 = cur if @arg1 != cur
      end
      cur
    end

    def apply(arg)
      Expr.new(:A, self, arg)
    end

    def eval()
      # call-by-needで評価を行う
      cur = self
      stack = []
      while true
        cur = cur.drop_i1
        while cur.type == :A
          stack << cur
          cur = cur.arg1.drop_i1
        end
        if stack.empty?
          return cur
        end
        a = cur
        cur = stack.pop
        cur.arg1 = a
        cur.eval_primitive
      end
    end

    def eval_primitive()
      # selfの内容を評価結果で上書きする(メモ化)
      lhs = @arg1
      rhs = @arg2.drop_i1
      @arg1 = @arg2 = nil
    case lhs.type
      when :FALSE
        @type = :I
      when :I
        @type = :I1
        @arg1 = rhs
      when :K
        @type = :K1
        @arg1 = rhs
      when :K1
        @type = :I1
        @arg1 = lhs.arg1
      when :S
        @type = :S1
        @arg1 = rhs
      when :S1
        @type = :S2
        @arg1 = lhs.arg1
        @arg2 = rhs
      when :S2
        @arg1 = lhs.arg1.apply(rhs)
        @arg2 = lhs.arg2.apply(rhs)
      when :READ
        reader = lhs.arg1
        pos = lhs.arg2
        ch = reader[pos]
        readnext = Expr.new(:READ, reader, pos+1)
        @arg1 = rhs.apply(ch)
        @arg2 = readnext
        # lhsも(cons ch readnext) = \b. b ch readnext となるよう書き換えておく
        # S(SI(K c))(K r) = \b.(SI(K c)b)(K r b) = \b.(I b (K c b)) r = \b. b c r
        lhs.type = :S2
        lhs.arg1 = Expr.new(:S2, Expr::I, Expr.new(:K1, ch))
        lhs.arg2 = Expr.new(:K1, readnext)
      when :CN
        @type = :CN1
        @arg1 = lhs.arg1
        @arg2 = rhs
      when :CN1
        if lhs.arg2.type == :INC && rhs.type == :NUM
          @type = :NUM
          @arg1 = lhs.arg1 + rhs.arg1
        else
          f = lhs.arg2
          x = rhs
          lhs.arg1.times{ x = f.apply(x) }
          @type = x.type
          @arg1 = x.arg1
          @arg2 = x.arg2
        end
      when :INC
        rhs = rhs.eval if rhs.type != :NUM
        if rhs.type == :NUM
          @type = :NUM
          @arg1 = rhs.to_i + 1
        else
          raise "invalid output format (attempted to apply inc to a non-number): (#{rhs.inspect})"
        end
      when :NUM
        raise "invalid output format (attempted to apply a number): #{lhs.inspect} #{rhs.inspect}"
      else
        raise ScriptError.new("unexpected state: lhs=#{lhs.inspect} rhs=#{rhs.inspect}")
      end
    end

    def to_i
      if @type == :NUM
        @arg1
      else
        raise "invalid output format (result was not a number): #{self.inspect}"
      end
    end

    def to_s
      case @type
      when :A then "[#{@arg1.to_s}, #{@arg2.to_s}]"
      when :I1, :S1, :K1 then "#{@type}(#{@arg1.to_s})"
      when :S2 then "S2(#{@arg1.to_a}, #{@arg2.to_s})"
      when :CN then "CN(#{@arg1})"
      when :CN1 then "[CN(#{@arg1}), #{@arg2.to_s}]"
      when :NUM then @arg1.to_s
      else @type.inspect
      end
    end
  end

  def initialize(stdin = $stdin, stdout = $stdout)
    @stdout = stdout
    @output_buf = []

    @stdin = stdin
    @input_buf = []
    @input_isEOF = false

    @cnums = (0..256).map{|i| Expr.new(:CN, i) }
  end

  private
  def car(e) = e.apply(Expr::K)
  def cdr(e) = e.apply(Expr::FALSE)
  def cn2i(e) = e.apply(Expr::INC).apply(Expr::NUM0).eval.to_i

  def readc(i)
    while i >= @input_buf.size && !@input_isEOF
      begin
        flush_output
        @input_buf += @stdin.readline.bytes
      rescue EOFError
        @input_isEOF = true
      end
    end
    if i < @input_buf.size
      @cnums[@input_buf[i]]
    else
      @cnums[256]
    end
  end

  def flush_output
    return if @output_buf.empty?
    @stdout.print @output_buf.pack("C*").force_encoding(Encoding::UTF_8)
    @output_buf.clear
  end

  def writec(c)
    @output_buf << c
    if c == 10
      flush_output
    end
  end

  def print_list(lst)
    while true
      begin
        c = cn2i(car(lst))
        if c >= 256
          flush_output
          return c-256
        else
          writec(c)
        end
        lst = cdr(lst)
      rescue
        flush_output
        raise "invalid output format"
      end
    end
  end

  def parse(input)
    stack = []
    line = 0
    input.each_line{|l|
      line += 1
      l.scan(/スロー|クイック|\u2764/).each{|tk|
        case tk
        when "スロー" then stack << Expr::S
        when "クイック" then stack << Expr::K
        when "\u2764" then
          if stack.size < 2
            raise SyntaxError.new("line #{line}: unexpected \u2764")
          end
          f = stack.pop
          a = stack.pop
          stack << f.apply(a)
        end
      }
    }
    if stack.size > 1
      raise SyntaxError.new("line #{line}: unexpected EOF")
    end
    stack[0]
  end

  def ast2expr(e)
    case e
    in [f, a] then ast2expr(f).apply(ast2expr(a))
    in :S then Expr::S
    in :K then Expr::K
    in :I then Expr::I
    else raise "unknown expr: #{e}"
    end
  end

  def run(srcinput)
    expr = parse(srcinput.read)
    if expr.nil?
      raise "failed loading program from #{srcinput.inspect}"
    end
    input = Expr.new(:READ, method(:readc), 0)
    print_list(expr.apply(input))
  end

  def run_file(filepath)
    File.open(filepath, "r"){|f| run(f) }
  end
  public :parse, :run, :run_file
end

def show_help_and_exit
  puts "usage: ruby honestb.rb prog.hb"
  exit(1)
end

if __FILE__ == $0
  if ARGV.length == 0
    if $stdin.tty?
      show_help_and_exit
    else
      require "stringio"
      exit HonestB.new(StringIO.new("")).run($stdin)
    end
  else
    if ARGV[0] == "-h" || ARGV[0] == "--help"
      show_help_and_exit
    else
      exit HonestB.new($stdin).run_file(ARGV[0])
    end
  end
end
