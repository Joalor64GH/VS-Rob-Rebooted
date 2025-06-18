function onCreate()
	makeLuaSprite('bg', 'cityStage/cityStage', -600, -600);
	setLuaSpriteScrollFactor('sky', 1, 1);

	addLuaSprite('bg', false);
	scaleLuaSprite('bg', 1.5, 1.5);
end

function onMoveCamera(focus)
    if focus == 'dad' then
        setProperty('camFollow.y', getProperty('camFollow.y') -50);
        setProperty('camFollow.x', getProperty('camFollow.x') +200);
    elseif focus == 'boyfriend' then
        setProperty('camFollow.y', getProperty('camFollow.y') -200);
        setProperty('camFollow.x', getProperty('camFollow.x') -300);
    end
end