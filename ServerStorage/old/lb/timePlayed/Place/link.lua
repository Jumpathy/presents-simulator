local info = {
	username = script.Parent:WaitForChild("Info"):WaitForChild("Username"),
	stat = script.Parent:WaitForChild("Info"):WaitForChild("Stat"),
	place = script.Parent:WaitForChild("Place"),
	thumbnail = script.Parent:WaitForChild("Thumbnail")
};

return function(place,id,stat,thumbnail,name)
	info.place.Text = ("#"..place);
	info.stat.Text = stat;
	info.username.Text = name;
	info.thumbnail.Image = thumbnail;
end