echo "Building nanoloot and installing to WoW's Addons directory."

echo "Creating TOC file..."
touch nanoloot.toc.tmp
cat nanoloot.toc > nanoloot.toc.tmp
sed -i "s/@project-version@/$(git describe --abbrev=0)/g" nanoloot.toc.tmp

echo "Copying assets..."
mkdir -p /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/nanoloot/
cp *.lua /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/nanoloot/
cp nanoloot.toc.tmp /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/nanoloot/nanoloot.toc

echo "Cleaning up..."
rm nanoloot.toc.tmp

echo "Complete."