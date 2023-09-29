
class LazyK2HonestB
  def initialize(cpl, input=$<, output=$>)
    @count = 0
    @buf = []
    @chars_per_line = cpl
    @input = input
    @output = output
  end

  def read_lazyk
    expr = read1
    while e = read1
      expr = [expr, e]
    end
    expr
  end

  def read1
    stack = []
    cur = nil
    while true
      while true
        begin
          c = @input.readchar
        rescue EOFError
          c = nil
          break
        end
        if c =~ /[`ski]/ || c.nil?
          break
        end
      end

      case c
      when nil
        if stack.empty? && cur.nil?
          return nil
        else
          raise "unexpected EOF"
        end
      when "`"
        stack << cur if cur
        cur = []
      when "s" then cur << :S
      when "k" then cur << :K
      when "i" then cur << [[:S, :K], :K]
      end
      while cur.length == 2
        if stack.empty?
          return cur
        end
        prev = stack.pop
        prev << cur
        cur = prev
      end
    end
    nil
  end

  def print1(tk)
    @count += tk.length
    if @count >= @chars_per_line
      @output.puts @buf.join
      @buf.clear
      @count = tk.length
    end
    @buf << tk
  end

  def flush()
    @output.puts @buf.join
    @buf.clear
    @count = 0
  end

  def print_hb(expr)
    stack = [expr]
    until stack.empty?
      e = stack.pop
      case e
      in :S then print1("スロー")
      in :K then print1("クイック")
      in :App then print1("\u2764")
      in [e1, e2]
        stack << :App
        stack << e1
        stack << e2
      end
    end
  end

  def run
    print_hb(read_lazyk)
    flush
  end
end

if ARGV[0] == "-h" || ARGV[0] == "--help"
  puts "usage: ruby lazyk2hb.rb prog.lazyk > prog.hb"
  puts "    or cat prog.lazyk | ruby lazyk2hb.rb > prog.hb"
else
  LazyK2HonestB.new(39).run
end
