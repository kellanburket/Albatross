require_relative "./xml.rb"

module PList

	class Doc < Xml::Doc

		def initialize(nodes = {})
			super("plist", {version: "1.0"})
			doctype = Xml::DocType.new [
				"plist", 
				"PUBLIC", 
				"\"-//Apple//DTD PLIST 1.0//EN\"", 
				"\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\""
			]

			@doc.addChildBefore(doctype, @root)
			
			@root.addChild Node.dict(nodes)
		end

	end

	class Node < Xml::Node

		def initialize(tag, content = nil)
			super(tag, {}, content)
		end

		def self.string(content)
			Node.new(:string, content)
		end

		def self.dict(properties)
			dict = Node.new(:dict)

			properties.each do |k, v|
				dict.addChild Node.key(k)
				dict.addChild self.parse(v)
			end

			return dict
		end

		def self.float(content)
			return Node.new(:float, content)
		end

		def self.int(content)
			return Node.new(:int, content)
		end

		def self.bool(content)
			return Node.new(content ? "true" : "false")
		end

		def self.array(properties)
			arr = Node.new(:array, properties)
			properties.each do |v|
				arr.addChild self.parse(v)
			end
			return arr
		end

		def self.key(content)
			Node.new(:key, content)
		end

		def self.parse(v)
			if v.is_a? Array
				return Node.array(v)
			elsif v.is_a? Hash
				return Node.dict(v)
			elsif v.is_a? Integer
				return Node.int(v)
			elsif v.is_a? Float
				return Node.float(v)
			elsif !!v == v
				return Node.bool(v)
			else
				return Node.string(v)
			end
		end

	end

end