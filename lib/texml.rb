# -*- ruby -*-

require 'nokogiri'

module TeXML
  # Converts a TeXML document, passed as a raw XML string, into the
  # corresponding (La)TeX document.
  def TeXML.convert(xml)
    document = Nokogiri::XML(xml)
    TeXML::Node.create(document.root).to_tex
  end

  # Escaping sequences for LaTeX special characters
  SPECIAL_CHAR_ESCAPES = {
    '%'[0] => '\%{}',
    '{'[0] => '\{',
    '}'[0] => '\}',
    '|'[0] => '$|${}',
    '#'[0] => '\#{}',
    '_'[0] => '\_{}',
    '^'[0] => '\\char`\\^{}',
    '~'[0] => '\\char`\\~{}',
    '&'[0] => '\&{}',
    '$'[0] => '\${}',		#'
    '<'[0] => '$<${}',		#'
    '>'[0] => '$>${}',		#'
    '\\'[0] => '$\\backslash${}'#'
  }

  # Given a raw string, returns a copy with all (La)TeX special
  # characters properly quoted.
  def TeXML.quote(str)
    tex = ''
    str.each_byte do |char|
      tex << (SPECIAL_CHAR_ESCAPES[char] or char)
    end
    return tex
  end

  # Keeps track of which classes can handle which type of nodes
  NODE_HANDLERS = Hash.new
  
  # Common node superclass (also node factory, see Node#create)
  class Node

    # Creates a node handler object appropriate for the specified XML
    # node, based on the name of the node (uses information from
    # NODE_HANDLERS).
    def Node.create(node)
      kind = node.name
      kind = '#text' if kind == 'text'
      handlerClass = NODE_HANDLERS[kind]
      if !handlerClass.nil?
	handlerClass.new(node)
      else
	nil
      end
    end

    def initialize(node)
      @node = node
    end

    # Aggregates the values of all the children of this Node whose
    # node name is included in the parameters, in the document order
    # of the children.
    def childrenValue(*childTypes)
      tex = ''
      @node.children.each do |kid|
	if childTypes.include?(kid.name) || (kid.text? && childTypes.include?('#text'))
	  node = Node.create(kid)
	  tex << node.to_tex unless node.nil?
	end
      end
      return tex
    end
  end

  class TexmlNode < Node
    NODE_HANDLERS['TeXML'] = TexmlNode

    def to_tex
      return childrenValue('cmd', 'env', 'ctrl', 'spec', '#text')
    end
  end

  class CmdNode < Node
    NODE_HANDLERS['cmd'] = CmdNode

    def to_tex
      name = @node['name']
      nl_before = (@node['nl1'] == '1') ? "\n" : ''
      nl_after = (@node['nl2'] == '1') ? "\n" : ''
      return nl_before + "\\#{name}" + childrenValue('opt') + childrenValue('parm') + ' ' + nl_after
    end
  end

  class EnvNode < Node
    NODE_HANDLERS['env'] = EnvNode

    def to_tex
      name = @node['name']
      start = @node['begin']
      start = 'begin' if start == ''
      stop = @node['end']
      stop = 'end' if stop == ''
      return "\\#{start}{#{name}}\n" +
	childrenValue('cmd', 'env', 'ctrl', 'spec', '#text') +
	"\\#{stop}{#{name}}\n"
    end
  end

  class OptNode < Node
    NODE_HANDLERS['opt'] = OptNode

    def to_tex
      return "[" + childrenValue('cmd', 'ctrl', 'spec', '#text') + "]"
    end
  end

  class ParmNode < Node
    NODE_HANDLERS['parm'] = ParmNode

    def to_tex
      return "{" + childrenValue('cmd', 'ctrl', 'spec', '#text') + "}"
    end
  end

  class CtrlNode < Node
    NODE_HANDLERS['ctrl'] = CtrlNode

    def to_tex
      ch = @node['ch']
      unless ch.nil?
	return ch & 0x9F	# Control version of ch
      else
	nil
      end
    end
  end

  class GroupNode < Node
    NODE_HANDLERS['group'] = GroupNode
    
    def to_tex
      return "{" + childrenValue('cmd', 'env', 'ctrl', 'spec', '#text') + "}"
    end
  end

  class SpecNode < Node
    NODE_HANDLERS['spec'] = SpecNode

    SPECIAL_MAP = {
      'esc'	=> "\\",
      'bg'	=> '{',
      'eg'	=> '}',
      'mshift'	=> '$',		# '
      'align'	=> '&',
      'parm'	=> '#',
      'sup'	=> '^',
      'sub'	=> '_',
      'tilde'	=> '~',
      'comment'	=> '%'
    }

    def to_tex
      cat = @node['cat']
      return (SPECIAL_MAP[cat] or '')
    end
  end

  class TextNode < Node
    NODE_HANDLERS['#text'] = TextNode

    def to_tex
      parent = @node.parent
      if parent.name == 'env' && parent['name'] == 'verbatim'
	return @node.to_s
      else
        return TeXML.quote(@node.to_s)
      end
    end
  end

end
