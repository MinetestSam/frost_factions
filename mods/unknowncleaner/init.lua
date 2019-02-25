minetest.register_entity("playertag:tag",
	on_step=function(self, dtime)
		self.object:remove()
	end,
	on_activate=function(self, dtime)
		self.object:remove()
	end
})
