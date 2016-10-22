
module TheFox
	module TermKit
		
		class ViewController < Controller
			
			attr_accessor :app
			attr_accessor :view
			
			def initialize(view = nil)
				if !view.nil? && !view.is_a?(View)
					raise ArgumentError, "Argument is not a View -- #{view.class} given"
				end
				
				super()
				
				@app = nil
				@view = view
			end
			
			def render(area = nil)
				@view.render(area)
			end
			
		end
		
	end
end
