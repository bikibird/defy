pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--defy audio player
--by bikibird
--inspired by https://www.lexaloffle.com/bbs/?tid=41991

function defyPlayer(clip,loop)
	local i
	local buffer,index=0x8000,1
	while true do
		while stat(108)<1536 do
			for i=0,511 do
				poke (buffer+i,ord(clip,index))
				index+=1
				if (index>#clip) then
					if (loop) then
						index=1
					else
						serial(0x808,buffer,i)
						return
					end
				end
			end
			serial(0x808,buffer,512)
		end
		yield()
	end	
end
---audio.clips[1]="abcdefghihgfedcb"
_init=function()
	audio=cocreate(defyPlayer)
end
_update=function()
	
	if (not btn(5)) then
		coresume(audio,"abcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcbabcdefghihgfedcb",true)
		
	end	
end
