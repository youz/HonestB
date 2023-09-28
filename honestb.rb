#!/usr/bin/env ruby

require "strscan"

class HonestB

  class Expr
    # https://sange.fi/esoteric/essie2/download/lazy-k/lazy.cpp を移植

    attr_accessor :type, :arg1, :arg2

    def initialize(t, a1 = nil, a2 = nil)
      @type = t
      @arg1 = a1
      @arg2 = a2
    end

    def drop_i1
      if @type == :I1
        cur = @arg1
        while cur.type == :I1
          cur = cur.arg1
        end
        @arg1 = cur if @arg1 != cur
        cur
      else
        self
      end
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
      rhs = @arg2
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
        lhs.arg1 = Expr.new(:S2, Expr.new(:I), Expr.new(:K1, ch))
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
          lhs.arg1.times{ f = f.apply(x) }
          @type = :A
          @arg1 = f.arg1
          @arg2 = f.arg2
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
        raise "invalid appliation form: fun=#{lhs.inspect} arg=#{rhs.inspect}"
      end
    end

    def to_i
      if @type == :NUM
        @arg1
      else
        raise "invalid output format (result was not a number): #{self.inspect}"
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
    @S = Expr.new(:S)
    @K = Expr.new(:K)
    @FALSE = Expr.new(:FALSE)
    @INC = Expr.new(:INC)
    @NUM0 = Expr.new(:NUM, 0)
  end

  private
  def car(e) = e.apply(@K)
  def cdr(e) = e.apply(@FALSE)
  def cn2i(e) = e.apply(@INC).apply(@NUM0).eval.to_i

  def readc(i)
    while i >= @input_buf.size && !@input_isEOF
      begin
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

  def parse(src)
    ss = StringScanner.new(src)
    stack = []
    line = 1
    lastlf = 0
    while true
      unless ss.scan_until(/スロー|クイック|\u2764|\n/)
        break
      end
      case ss.matched
      when "\n"
        line += 1
        lastlf = ss.charpos
      when "スロー"
        stack << :S
      when "クイック"
        stack << :K
      when "\u2764"
        if stack.size < 2
          col = ss.charpos - lastlf
          p stack
          raise "line #{line}: column #{col}: syntax error, unexpected \u2764"
        end
        f = stack.pop
        a = stack.pop
        stack << [f, a]
      end
    end
    if stack.size > 1
      raise "line #{line}: syntax error, unexpected EOF"
    end
    stack[0]
  end

  def ast2expr(e)
    case e
    in [f, a] then ast2expr(f).apply(ast2expr(a))
    else Expr.new(e)
    end
  end

  def run(src)
    expr = ast2expr(parse(src))
    input = Expr.new(:READ, method(:readc), 0)
    print_list(expr.apply(input))
  end

  public :parse, :run
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
      src = $stdin.read
      require "stringio"
      stdin = StringIO.new("")
    end
  else
    if ARGV[0] == "-h" || ARGV[0] == "--help"
      show_help_and_exit
    else
      src = File.open(ARGV[0]).read
      stdin = $stdin
    end
  end
  exit HonestB.new(stdin).run(src)
end
