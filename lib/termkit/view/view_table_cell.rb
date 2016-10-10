
module TheFox
	module TermKit
		
		class CellTableView < View
			
			def initialize(subview, name = nil)
				name = "CellTableView_#{object_id}" if name.nil?
				super(name)
				
				add_subview(subview)
			end
			
		end
		
	end
end
