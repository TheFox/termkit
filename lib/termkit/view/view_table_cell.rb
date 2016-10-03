
module TheFox
	module TermKit
		
		class CellTableView < View
			
			def initialize(subview)
				super("CellTableView_#{object_id}")
				
				add_subview(subview)
			end
			
		end
		
	end
end
