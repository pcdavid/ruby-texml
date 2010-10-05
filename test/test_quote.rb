require File.join(File.dirname(__FILE__), '..', 'texml.rb')
require 'test/unit'

class QuotingTest < Test::Unit::TestCase
  def test_empty
    assert_equal '', TeXML.quoteTeXString('')
  end

  def test_nil
    assert_raise(NoMethodError) { TeXML.quoteTeXString(nil) }
  end

  def test_no_special_chars
    assert_equal 'lore ipsum', TeXML.quoteTeXString('lore ipsum')
  end

  def test_special_chars
    assert_equal 'outside \{inside\} \{\{deep \{\{inside\}\}\} a group\}', TeXML.quoteTeXString('outside {inside} {{deep {{inside}}} a group}')
  end
end
