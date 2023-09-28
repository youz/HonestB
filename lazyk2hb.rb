
class LazyK2HonestB
  def initialize(cpl, input=$<, output=$>)
    @count = 0
    @buf = []
    @chars_per_line = cpl
    @input = input
    @output = output
  end

  def read_lazyk
    begin
      c = @input.readchar
    rescue EOFError
      raise "unexpected EOF"
    end until c =~ /[`ski]/
    case c
    when "`" then [read_lazyk, read_lazyk]
    when "s" then :S
    when "k" then :K
    when "i" then [[:S, :K], :K]
    end
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
    case expr
    in [e1, e2]
      print_hb(e2)
      print_hb(e1)
      print1("\u2764")
    in :S then print1("スロー")
    in :K then print1("クイック")
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
