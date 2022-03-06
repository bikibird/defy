pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- defy, a pcm boombox
-- by bikibird
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

buffer=0x8000
pcm_string=""
index=0
recording=false
predicted_sample,ad_index = 0,0
step = 7
function load(a_pcm_string,looping)  --load audio from pcm string and intialize
	pcm_string=a_pcm_string
	loop=looping or false
	done=false
	index=1
	pcm_value=0
	next_value=0
end
function play()  --play from pcm string
	if not done then
		local i
		while stat(108)<1536 do
			for i=0,511 do
				poke (buffer+i,ord(pcm_string,index))
				index+=1
				if (index>#spcm_string) then
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
function play_from_serial()
	if not done then
		local request
		local next_value
		local i=0
		while stat(108)<1536 do
			if stat(120) then
				receipt = serial(0x800, buffer, 512)
				if (recording==true) update_pcm_string(receipt)
				serial(0x808,buffer,receipt)	
			end
		end	
	end	
end
function record(lossy_option)  --add lossy vs lossless options
	pcm_string=""
	recording=true
	lossy=lossy_option or false
end
function escape_binary_str(s)  --https://www.lexaloffle.com/bbs/?tid=38692
	local out=""
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
function adpcm(sample) --http://www.cs.columbia.edu/~hgs/audio/dvi/IMA_ADPCM.pdf
	local indexTable = {[0]=–1, –1, –1, –1, 2, 4, 6, 8, –1, –1, –1, –1, 2, 4, 6, 8)
	local stepTable = {[0]=7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60,66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 1528}
	local delta = sample – predicted_sample;
	local i
	if delta >= 0 then
		new_sample = 0
	else
		new_sample = 8
		delta = –delta
	end
	local mask = 4
	local temp_step = step

	for i = 0,3 do
		if delta >= temp_step then
			new_sample |= mask 
			delta –= temp_step 
		end
		temp_stepsize >>>=1; /* adjust comparator for next iteration */
		mask >>>=1; /* adjust bit-set mask for next iteration */
	end
	new_sample &=15 --truncate decimal portion
	delta= 0
	if (new_sample & 4 >0) delta += step
	if (new_sample & 2 > 0) delta += step >>> 1
	if (new_sample & 1) delta += step >>> 2
	delta += step >> 3
	if (newSample & 8 >0) delta = –delta
	predicted_sample += delta
	if (predictedSample > 32767) /* check for overflow */
predictedSample = 32767;
else if (predictedSample < –32768)
predictedSample = –32768;
/* compute new stepsize */
/* adjust index into stepsize lookup table using newSample */
index + = indexTable[newSample];
if (index < 0) /* check for index underflow */
index = 0;
else if (index > 88) /* check for index overflow */
index = 88;
stepsize = stepsizeTable[index]; /* find new quantizer stepsize */
end





function update_pcm_string(receipt)
	local n=0
	if #pcm_string==0 then
		pcm_value=@buffer
		pcm_string=chr(pcm_value)
		n=1
	end	
	if #pcm_string < 32000 then
		for i=n,receipt-1 do
			next_value=@(buffer+i)
			pcm_string..=chr(next_value-pcm_value)
			pcm_value=next_value
		end
	else
		recording=false
		printh(escape_binary_str(pcm_string),"@clip")
		print("copied")
	end	
end	
_init=function()
	--defy_player:load"○○██○○▒█○○▒○██○○░○○██○🐱○○○○{▒████✽○○○○🐱○████}~○○○~|▒███y○○█○○z▒█○█▒○}~█🐱○✽🐱▒wy▒~웃░✽⬇️○~⬇️○█🐱}░}█●▒▒█○~🐱~~z███▒█⬇️▒⬇️|}v|░🐱█~✽{○○n▒○█v○y⌂█z🐱~{▒}○▒x🐱░~||ww🐱웃🐱🐱░▒♥uz○○●웃░~⬆️{}}}✽█~▒○}●⬇️{⬇️{sx⬅️☉░uv}~}░▒~}z~░▒♥○}}|▒~⬇️█▒█{~🐱⌂○⬇️}|○}█⬇️⬇️}█{z🐱~🐱♪░▒█○t♥~░…⬇️🐱○○p○{●⬆️⬇️░|wt|~▒🅾️☉░|wvxy█🅾️✽☉█z{w|▒웃z▒⬇️|░▒○○▒}{⬇️}🐱🐱○🐱✽y}▒~|░{█⬅️○}}l~█⬇️🅾️░🐱sv}z◆░░{p~z🐱⬅️●█vw}{⌂▒☉wu○z♥웃z|ww○{⬅️🐱▒ws}}🅾️⬅️x▒rz{⬇️🅾️✽░qq○|⧗◆❎~lmn●░∧🅾️zsit🐱➡️お🅾️░mdt▒★▤웃zlmv●▤➡️✽wiy⬇️⬇️◆█wtw○⬅️◆░vqi⬇️♪◆➡️🐱pks●⧗⬆️⬇️soax…ˇ⧗○nin♥…⧗웃uss█웃♪░wxs{♪●☉}oqx●…⧗●womt⌂➡️…♥tiq🐱♪❎♪|tww웃🐱◆○█yxx}█★✽🐱ulx~∧🅾️○nky🅾️◆∧xxk}⬅️➡️♪zpz~⌂…○~y🐱z~z}▒⌂▒▒s}w☉🅾️♪|qqy…◆⬇️sn}♪❎웃wju░◆웃|pv⬇️…⬅️}mq█う⧗}jg|★⧗웃qjn웃◆★}ni○➡️▤♥qj|…♪●mqy★♪⌂sss☉☉…wnm▒★♪○kn~ˇ★☉nnt😐➡️😐ysr░⬅️♪●oqz⌂♪♥vtt●⌂⬅️{ys░●✽|||○░♥uv}⬅️😐░{rqx😐☉○vz~✽🐱○|⬇️█☉♥○█⬇️⬇️}z|○●🐱{yu~●█|w▒웃웃}vx~웃…~x}█●○}x🐱░⬇️✽{s░█✽{~○웃▒}z█~|✽~▒}⬇️}█w▒█♥▒|█~●🐱~s}⬇️⌂⬇️○x{⬇️{░|█~⌂█{y~~⬇️░z●|●~▒t▒░♥○}|}♥}█r○▒♪▒█w{✽🐱♥z█}웃▒~x~}░▒z~y✽~▒z▒▒🐱~○~▒░z🐱|⬇️█♥~○○}☉⬇️sw⬅️●ws▒🐱{w♥⌂||}웃█sr⬅️😐▒t|⬅️●█p웃웃~s░○█p{⌂♪yq☉😐▒w|🐱⌂su✽웃○w○●✽yx☉♪wr🐱⬇️✽t|◆웃zu~웃█{○⬇️🐱r}✽⬇️|○○~○z○~⬇️█}{~✽⬇️y웃░}{░✽~⬇️{☉☉wv█░▒▒}z🐱yz웃✽~{█|░}y✽●{z▒█⬇️●y░☉|w}✽⬇️|z○웃ws⬇️😐▒v|✽✽xx✽웃zv~🐱🐱▒{✽░|}⬇️~⬇️█|○▒░wu⌂v|✽⬇️q⬇️★zi☉❎~n…🅾️ksˇ✽m}🅾️}p}⬅️~x★░g}▥}f✽▤~j|…zv⬅️웃r}🅾️yq♪😐yt😐♥kzˇ⬇️h▒ˇ|p~⌂█x▒☉}u✽☉🐱u{⬅️▒u🐱😐zt☉🅾️tr⬅️♥▒b⌂∧\\░▥l█☉⬇️⌂k▒おbuいk}😐{♪o{かhkきxr✽v😐{nけziう{m⌂{웃~iお▒`ˇ웃l⬅️w✽☉g●ˇi😐▒u◆○n⬆️wx∧k~⬆️a★░g▤}lかlyあd⬇️⧗a…웃fいtrくhsおd⌂⬅️a❎♥fおnrさhu▥f…⌂_お🐱`くtlえj█❎`⬆️◆\\あ⬇️cうptおc▒お^🅾️…c❎{jおiwきb⬇️あd➡️●dいtkかhwさd♥★e∧⬇️^かslおlzえe😐…b❎🐱dうtnうk}⬆️e🅾️♪b⬆️⬇️m▤ruいl~…h⬅️⬅️g★▒rˇtx∧l█♪i⌂♥m…~v⬆️tz➡️n🐱☉m웃✽q…|x➡️xz⬅️q⬇️✽p♥⬇️v♪|{◆x|♥s░⬇️o☉░y⌂{~🅾️v{♥t⬇️▒s☉░x⌂|~웃w{♥u⬇️▒w☉⬇️y⌂|~●w~░u⬇️⬇️y♥█|⌂{|●w▒⬇️u░⬇️z☉}|⌂{|●v🐱⬇️v░🐱z웃|{☉{~✽u░⬇️w░▒y⬅️{|♥z○✽s✽🐱x✽█y😐z~♥y█●s✽▒w☉~y⬅️z○☉w▒✽v●○v웃}{☉y█웃v⬇️⬇️w●~w웃{|☉x▒●u✽🐱v♥~y웃y~웃w▒✽u●█x☉~z⌂x█●w▒░u♥○z웃}{☉y▒✽u🐱🐱y●~{⬅️|~●y▒⬇️t⬇️█y♥~}☉|█✽x▒▒x░~{♥~○✽{▒⬇️y🐱○|✽}}✽}▒🐱{⬇️█{⬇️~~⬇️}█⬇️|🐱█}⬇️~}⬇️|█▒{🐱▒}🐱~○✽}██}🐱○{⬇️~○░|█⬇️|⬇️○{░○}░{▒░{▒▒z✽}|░~○✽z🐱🐱z🐱○z✽}}●|█░z▒▒y░~|░~~✽{🐱⬇️z🐱█{░}}✽}○⬇️|🐱🐱|▒█|⬇️}~🐱~○🐱|▒█}▒█~🐱~○▒~○▒~██○▒○○█○○█○○█○█▒○██○○█○○████~██○○○○▒○○█○██~○█○▒○○▒█○▒○○█○○█~██○██○█○○█~○█○██○▒○~▒○○█~█▒~██~▒○○▒○○▒~██~██~█○○▒○█▒○▒█}█○○▒~█▒○██~▒○~▒○○▒○█▒~██~█○○▒~○████~▒█○██○▒~○█○○█○▒█○█○○█~██○█○██○○█○█○○█○██○█○○█○○█○██○██○█○○█○○█~▒█~▒█○▒~○▒~○▒~▒█~▒○~▒~○▒~██~▒○~🐱~○▒}█▒}▒█}🐱○~🐱~○🐱}█▒}▒○~🐱○○🐱~█▒~██}▒○~▒~○▒~█▒~▒█~▒○~▒~○▒~██~▒○○▒○○▒~██~██~█○○▒○○▒○██~██○█○○▒○○█○██~██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○████○██○○○○○○○○█████○█○○○○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○██○█○○█○○█○○█○██○█○○█○○█○○█○██○█○○█○○█○██○██○█○○█○○█○○█○█○○█○○█○○█○█○○█○○█○○█○█○○█○○█○○█○██○█○○█○○○○○○○○○○█○○█○█○○○○○█○○█○█○○█○○○○○█○○█○██○█○○█○○○○○○○○█○█○○█○○█○○█○○○○█○○█○○█○○○○○█○█○○█○○○○○○○█○○○○○█○○█○○○○○○○○○○█○○○○○○○█○○○○○█○○○○○○○○○○█○○█○○○○○○○○○○○○○█○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○█○○█○○○○██○○○○○○○○○○○○█○○○○○○○○○○○○○○○○█○○○○█○○█○○█○○○○█○○█○○○○○█○○█○█○○○○○○○○○○○█○█○○○○○█○○█○○○○○○○○○○█○█○○○○○○○○○○○○█○█○○○○○█○○█○○█○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○█○○█○○○○○○○█○○█○○█○○○○█○○○○○○○○█○○○○○○○○○○○○○○○○○○○○█○○○○█○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○██○○○○○○○█○○○○○█○○○○○○○█○○○○○○○○█○○█○○○○○○○○○○○○○█○○█○█○○█○○○○○█○○○○█○○○○○█○○○○○○○○○○○○○○○○█○○○○○█○○○○○○○○○○█○○○○○○█○○█○██○○█○█○○█○██○█○○○○○○○○○○○○○█○○○○○○○○○○○○○○○○○○○○○○○○○█○○○○○███○○○○○█○○○○○○○○○█○○○○○○○○○██○○○○○○○○○○○○█○○██○○○○○○█○○○█○█○○█○○○○○█○█○○○○○○○○○█○○○○○○○○○○○○○○○○█○○█○○█○○█○○○○○○○█○○○○○○○█○○█○○○○○○○○█○██○○○█○██○○█○█○○○○○█○██○██○██○█○○█○○○○█○○○○○█○○█○○█○○○█○○██○○█○○○○██████████████████○○██○○█○█○█○○█○○○○○○○○█○○○○○○○██○○○○████○█○"
	
	
end
_update=function()
	play_from_serial()
	--play()
	if btnp(4) or btnp(5) then
		record()
		print"recording"
	end
end


