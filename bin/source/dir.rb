class Dir

	def self.scan(dir, file, options = {})
		found = nil

		ignore = options[:ignore].nil? ? [] : options[:ignore]
		
		scandir = ->(dir, tabs) {

			return Dir.glob("#{dir}/*") do |item|

				next if results = ignore.one? { |i| 
					File.basename(item) =~ /#{i}/
				} 

				if item.match /#{file}/
					if File.directory? item					
						return item
					else
						return File.dirname(item)
					end
				end

				if File.directory? item					
					if file = scandir.call(item, tabs + 1)
						return file
					end
				end			
			end

		}

		return scandir.call(dir, 1)
	end

end