function processFile(file,destination)
	{
		//https://developer.mozilla.org/en-US/docs/Web/API/OfflineAudioContext/startRendering

		var audioContext = new (window.AudioContext || window.webkitAudioContext)();
		var fileReader = new FileReader()
		fileReader.onload = function(e)
		{
	    	audioContext.decodeAudioData(e.target.result).then(function(buffer)
			{
				offlineAudioContext= new OfflineAudioContext(
				{
  					numberOfChannels: 1,
  					length: 5512.5 * buffer.duration,
  					sampleRate: 5512.5,
				})
				source = offlineAudioContext.createBufferSource()
				source.buffer = buffer
				
				source.connect(offlineAudioContext.destination)
				source.start()
				offlineAudioContext.startRendering().then(function(renderedBuffer)
				{
					var lastValue=0
					var character
					var binString=""

					var bin=renderedBuffer.getChannelData(0).map(data=>
						{	
							value=Math.floor(data*128)+128
							switch (value)
							{
								case 0: character="\\000"; break
								case 9: character="\\t"; break;
								case 10: character="\\n"; break;
								case 13: character="\\r"; break;
								case 92: character="\\\\"; break;
								case 34: character="\\\""; break;
								default: character=String.fromCharCode(value); break;
							}
							binString=binString+character
							//binString=binString+value.toString()+","
							return value
						})
						//binString=binString+"}"
					console.log(binString)
					playback(renderedBuffer)
				})
			})	
		}	  
		fileReader.readAsArrayBuffer(file)
	}
	function playback(buffer)
	{
		var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
		var sound = audioCtx.createBufferSource()
		sound.buffer = buffer
		sound.connect(audioCtx.destination)
		sound.start()
	}
	function escapeText(value)
	{
		var character =""
		switch (value)
		{
			case 0: character="\\000"; break
			case 1: character="¹"; break;
			case 2: character="²"; break;
			case 3: character="³"; break;
			case 4: character="⁴"; break;
			case 5: character="⁵"; break;
			case 6: character="⁶"; break;
			case 7: character="⁷"; break;
			case 8: character="⁸"; break;
			case 9: character="\\t"; break;
			case 10: character="\\n"; break;
			case 11: character="ᵇ"; break;
			case 12: character="ᶜ"; break;
			case 13: character="\\r"; break;
			case 14: character="ᵉ"; break;
			case 15: character="ᶠ"; break;
			case 92: character="\\\\"; break;
			case 34: character="\\\""; break;
			default: character=String.fromCharCode(value); break;
		}
		console.log(character)

		
	}