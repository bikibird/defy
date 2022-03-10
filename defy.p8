pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- defy, a pcm boombox
-- by bikibird
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

function load(an_audio_string,looping)  --load audio from pcm string and intialize
	audio_string=an_audio_string
	loop=looping or false
	done=false
	index=1

end
function play_pcm_string()  --play from pcm string
	if not done then
		local i
		while stat(108)<1536 do
			for i=0,511 do
				poke (buffer+i,ord(audio_string,index))
				index+=1
				if (index>#audio_string) then
					if (loop) then
						index=1
					else
						serial(0x808,buffer,i+1)
						done=true
						return true
					end
				end
			end
			serial(0x808,buffer,512)
		end
	end	
end
function play_adpcm_string()  --play from pcm string
	if not done then
		local i,c
		while stat(108)<1536 do
			for i=0,255 do
				c=ord(audio_string,index)
				poke (buffer+i*2,adpcm((c&0xf0)>>>4),adpcm(c&0x0f))
				index+=1
				if (index>#audio_string) then
					if (loop) then
						index=1
					else
						serial(0x808,buffer,i+1)
						done=true
						return true
					end
				end
			end
			serial(0x808,buffer,512)
		end
	end	
end
function play_pcm()
	if not done then
		local request
		local i=0
			while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 512)
			if (recording==true) update_audio_string(receipt)
			serial(0x808,buffer,receipt)	
		end	
	end	
end
function play_adpcm()
	if not done then
		local request
		local i
		while stat(108)<1536 and stat(120) do
			receipt = serial(0x800, buffer, 256)
			for i=0,receipt-1 do
				poke(audio_buffer+i*2,adpcm((@(buffer+i)&0xf0)>>>4),adpcm(@(buffer+i)&0x0f))
			end
			if (recording==true) update_audio_string(receipt)
			serial(0x808,audio_buffer,receipt*2)	
		end	
	end	
end
modes={{playback=play_pcm,caption="➡️ play pcm"},{playback=play_adpcm,caption="➡️ play adpcm"}}
function record(lossy_option)  --add lossy vs lossless options
	audio_string=""
	recording=true
end
function escape_binary_str(s)  --https://www.lexaloffle.com/bbs/?tid=38692
	local out=""
	local i
	for i=1,#s do
	 local c  = sub(s,i,i)
	 local nc = ord(s,i+1)
	 local pr = (nc and nc>=48 and nc<=57) and "00" or ""
	 local v=c
	 if(c=="\"") v="\\\""
	 if(c=="\\") v="\\\\"
	 if(ord(c)==0) v="\\"..pr.."0"
	 if(ord(c)==10) v="\\n"
	 if(ord(c)==13) v="\\r"
	 out..= v
	end
	return out
end
function adpcm(sample) --http://www.cs.columbia.edu/~hgs/audio/dvi/IMA_ADPCM.pdf, but adapted for 8 bit unsigned
	local index_table = {[0]=-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8}
	-- thanks @luchak and @packbat for advice on the step table.
	local step_table ={7,8,9,10,11,12,13,14,15,17,19,21,23,25,28,31,34,38,42,46,50,55,61,67,74,81,89,98,108,119,131,144,158,174,192,211,232,255}
	--{219,241,265,292,321,353,388,427,469,516,568,625,687,756,832,915,1006,1107,1218,1339,1473,1621,1783,1961,2157,2373,2610,2871,3158,3474,3822,4204,4624,5087,5595,6155,6770,7447} 
	--{63,69,76,84,92,101,111,123,135,148,163,179,197,217,239,263,289,318,350,385,423,465,512,563,619,681,750,824,907,998,1097,1207,1328,1461,1607,1767,1944,2139,2352,2588,2846,3131,3444,3788,4167,4584,5042,5547,6101,6712,7383,8121,8933,9826,10809,11890,13079,14387,15825,17408} 
	--{[0]=1,1,1,1,1,2,2,2,2,2,3,3,3,3,4,4,5,5,6,6,7,7,8,9,10,11,12,13,14,15,17,19,21,23,25,28,31,34,38,42,46,50,55,61,67,74,81,89,98,108,119,131,144,158,174,192,211,232,255}
	local delta=0
	if (sample & 4>0) delta += step
	if (sample & 2>0) delta += flr(step >>> 1)
	if (sample & 1>0) delta += flr(step >>> 2)
	delta += flr(step>>>3)
	if (sample> 8) delta = -delta
	new_sample +=delta
	if new_sample >255 then	
		new_sample = 255
	elseif new_sample < 0 then
		new_sample = 0
	end	
	
	ad_index += index_table[sample]
	if ad_index < 1 then 
		ad_index = 1
	elseif (ad_index >= #step_table) then
		ad_index = #step_table
	end	
	step = step_table[ad_index]
	return new_sample
end
function update_audio_string(receipt)
	local i
	if #audio_string < 32000 then
		for i=0,receipt-1 do
			audio_string..=chr(@(buffer+i))
		end
	else
		recording=false
		printh(escape_binary_str(audio_string),"@clip")
		print("copied")
	end	
end	

function _init()
	audio_buffer=0x8000
	mode=1
	buffer=0xa000
	audio_string=""
	index=0
	recording=false
	new_sample,ad_index = 0,0
	step = 7
	extcmd("pause")
	--load""


end	
function choose_playback(b) 
	if(b&1 > 0) then -- left
		mode=mode-1
		if (mode < 1) mode=#mode
	elseif(b&2>0) then -- right
		mode=mode%#modes+1
	end
	playback=modes[mode].playback
	menuitem(_, modes[mode].caption)
	return true
end 
function choose_record(b) 
	if(b&1 > 0 or b&2>0) then
		recording=not recording
		if recording then
			menuitem(_, "➡️ recording")
		else
			menuitem(_, "➡️ not recording")
		end	
	end	
	return true
end 
menuitem(1, modes[1].caption,choose_playback)
menuitem(2, "➡️ not recording",choose_record)
_update=function()
	modes[mode].playback()
	
--play_adpcm_string()
end
