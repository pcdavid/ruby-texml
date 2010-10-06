# -*- ruby -*-
require 'rubygems'

spec = Gem::Specification.new do |spec|
  spec.name = 'texml'
  spec.version = '0.5.0'
  spec.summary = 'A TeXML to LaTeX converter.'
  spec.description = %{This program converts an XML document conforming to the TeXML syntax into the corresponding (La)TeX document, ready to be typeset. It is based on Douglas Lovell's paper: "TeXML: Typesetting with TeX", Douglas Lovell, IBM Research in TUGboat, Volume 20 (1999), No. 3}
  spec.author = 'Pierre-Charles David'
  spec.email = 'pcdavid@gmail.com'
  spec.homepage = 'http://github.com/pcdavid/ruby-texml'
  
  spec.executables = [ 'texml' ]
  spec.files = Dir['lib/*.rb'] + Dir['bin/texml']
  spec.has_rdoc = false
end
