local total = 0;

return {
	Backpacks = {
		{
			Model = "Backpack1",
			Price = 0,
			Storage = 100,
			Display = true
		},
		{
			Model = "Backpack2",
			Price = 2000,
			Storage = 800,
			Display = true
		},
		{
			Model = "Backpack3",
			Price = 15000,
			Storage = 2000,
			Display = true
		},
		{
			Model = "Backpack4",
			Price = 35000,
			Storage = 10000,
			Display = true,
			Change = true
		},
		{
			Model = "Backpack5",
			Price = 100000,
			Storage = 50000,
			Display = true
		},
		{
			Model = "Backpack6",
			Price = 500000,
			Storage = 150000,
			Display = true
		},
		{
			Model = "Backpack7",
			Price = 5000000,
			Storage = 3000000,
			Display = true
		},
		{
			Model = "Backpack8",
			Price = math.huge,
			Storage = math.huge,
			Display = true,
			Change = true,
			PassId = 24838183
		}
	},
	DataVersion = {
		Studio = 12 + total,
		Live = 3 + total,
		Boards = 3 + total,
	}
}