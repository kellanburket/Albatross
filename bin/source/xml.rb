module Xml
	
	class Doc

		@root
		@doc

		def initialize(tag, properties = {})
			@doc = Prologue.new
			@root = Node.new(tag, properties)
			@doc.addChild @root
		end

		def build
			@doc.build(0)
		end

		def read(doc)
			
		end

	end

	class Node

		@tag
		@root
		@indent

		def initialize(tag, attributes = {}, content = nil)
			@attributes = Hash.new
			@properties = Array.new
			@children = Array.new
			@content = nil

			@tag = tag
			@attributes = attributes
			@content = content
		end

		def open_indent
			return "\t" * @indent
		end

		def close_indent
			if @children.count > 0 
				return open_indent
			else
				return ""
			end
		end

		def increment_indent
			return @indent + 1
		end

		def prefix
			"<"
		end

		def postfix
			if @children.count == 0 && @content.nil?
				return "/>"
			else
				return ">"
			end
		end

		def addAttribute(name, attribute)
			@attributes[name] = attribute
		end

		def addProperty(property)
			@properties << property
		end

		def addChild(child)
			#@children = @children ? @children : Array.new
			@children << child
		end

		def addChildBefore(child, node)
			i = @children.find_index(node)

			if i > 0 
				@children.insert(i - 1, child)
			else
				@children.unshift(child)
			end
		end

		def addChildAfter(child, node)
			i = @children.find_index(node)
			@children.insert(i, child)
		end

		def addChildren(children)
			children.each do |child|
				addChild(child)
			end
		end

		def build(tabs)
			@indent = tabs
			return "#{open_indent}#{open}#{body}#{close}\n"
		end

		def open
			output = "#{prefix}#{@tag} "

			@properties.each do |a|
				output += "#{a} "
			end

			@attributes.each do |k, v|
				output += "#{k}=\"#{v}\" "
			end

			output = "#{output.rstrip}#{postfix}"
		end

		def body
			output = ""

			if @content.nil? && @children.count > 0
				output += "\n"
				@children.each do |child|
					output += "#{child.build(increment_indent)}"
				end
			else
				output += @content.to_s
			end

			return output
		end

		def close
			if @children.count == 0 && @content.nil?
				return ""
			else
				return "#{close_indent}#{prefix}/#{@tag}#{postfix}"
			end
		end

	end

	class DocType < Node

		def initialize(properties)
			super "DOCTYPE"
			@properties = properties		
		end

		def increment_indent
			return 0
		end

		def prefix
			"<!"
		end

		def close
			return ""
		end

	end

	class Prologue < Node

		def initialize
			super "xml", {version: "1.0", encoding: "UTF-8"}
		end

		def increment_indent
			return 0
		end

		def prefix
			return "<?"
		end

		def postfix
			return "?>"
		end

		def close
			return ""
		end

	end

end