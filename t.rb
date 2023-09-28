require "minitest/autorun"
require "stringio"
require_relative "./honestb.rb"

class TestHonestB < Minitest::Test
  def setup
    @hb = HonestB.new
    [:cn2i, :car, :cdr, :ast2expr].each{|s| self.class.define_method(s){|*a| @hb.send(s, *a) }}
    @cons = ast2expr([[:S, [[:S, [:K, :S]], [[:S, [:K, :K]], [[:S, [:K, :S]], [[:S, [:K, [:S, :I]]], :K]]]]], [:K, :K]])
    @cnums = @hb.instance_variable_get("@cnums")
  end

  def test_parse
    assert_equal [[:S, :K], :K], @hb.parse("クイッククイックスロー❤❤")
    assert_equal [:S, [:K, :K]], @hb.parse("クイッククイック❤スロー❤")
    ["\u2764", "\u2764\ufe0e", "\u2764\ufe0f"].each {|c|
      assert_equal [:S, :K], @hb.parse("クイックスロー" + c)
    }
  end

  def test_primitive_cnum
    [0, 1, 2, 128, 256].each{|i|
      assert_equal i, cn2i(@cnums[i])
    }
  end

  def test_composed_cnum
    assert_equal 0, cn2i(ast2expr([:K, :I]))
    assert_equal 1, cn2i(ast2expr(:I))
    assert_equal 0, cn2i(ast2expr([:S, :K]))
    assert_equal 1, cn2i(ast2expr([[:S, :K], :K]))

    cn2 = [[:S, [[:S, [:K, :S]], :K]], :I] # ``s``s`kski
    assert_equal 2, cn2i(ast2expr(cn2))
    assert_equal 4, cn2i(ast2expr([cn2, cn2]))
    assert_equal 16, cn2i(ast2expr([[cn2, cn2], cn2]))
    assert_equal 256, cn2i(ast2expr([[cn2, cn2], [cn2, cn2]]))
  end

  def test_comb
    s = HonestB::Expr.new(:S)
    k = HonestB::Expr.new(:K)
    n1 = HonestB::Expr.new(:NUM, 1)
    n2 = HonestB::Expr.new(:NUM, 2)
    n3 = HonestB::Expr.new(:NUM, 3)
    assert_equal 1, k.apply(n1).apply(n2).eval.to_i
    assert_equal 2, k.apply(k).apply(n1).apply(n2).apply(n3).eval.to_i
    assert_equal 1, s.apply(k).apply(k).apply(n1).eval.to_i
  end

  def test_list
    l = [256, 255, 128, 0].map{|i| @cnums[i] }.reduce{|a, c|
      @cons.apply(c).apply(a)
    }
    assert_equal 0, cn2i(car(l)).to_i
    assert_equal 128, cn2i(car(cdr(l))).to_i
    assert_equal 255, cn2i(car(cdr(cdr(l)))).to_i
    assert_equal 256, cn2i(cdr(cdr(cdr(l)))).to_i
  end

  def test_output
    n0 = HonestB::Expr.new(:Num, 0)
    l = [0, 256, 67, 66, 65].map{|i| @cnums[i] }.reduce{|a, c| @cons.apply(c).apply(a) }
    stdin = StringIO.new("")
    stdout = StringIO.new
    HonestB.new(stdin, stdout).send(:print_list, l)
    assert_equal "ABC", stdout.string
  end

  def test_input
    stdin = StringIO.new("foo")
    stdout = StringIO.new
    hb = HonestB.new(stdin, stdout)
    input = HonestB::Expr.new(:READ, hb.method(:readc), 0)
    assert_equal 102, cn2i(car(input))
    assert_equal 111, cn2i(car(cdr(input)))
    assert_equal 111, cn2i(car(cdr(cdr(input))))
    assert_equal 256, cn2i(car(cdr(cdr(cdr(input)))))
  end

  def test_echo
    stdin = StringIO.new("ご友人\u2764\u2764")
    stdout = StringIO.new
    hb = HonestB.new(stdin, stdout)
    hb.run("クイッククイックスロー\u2764\u2764")
    assert_equal "ご友人\u2764\u2764", stdout.string
  end
end
