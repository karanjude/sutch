jQuery.fn.gallery = function(s,slideshow,styling) {	
		var gallery = this;
		var img = [];
		var speed = 1000; if(s) speed = parseInt(s,10);
		var ssOption = '<li><a href="#" id="playstop" title="Play/Stop SlideShow">&nbsp;</a></li>';
		var take = 0;
		if(slideshow==undefined) {
			slideShowSpeed = speed*2.5;
		} else if(slideshow) {
			slideShowSpeed = slideshow;
		} else if (!slideshow) {
			ssOption = '';
			take = 1;
		}
		var galleryStructure = '<div id="img-gallery"><img style="display:none" /><ul>'+ssOption+'</ul><div id="img-description"></div></div>';
		var started = false;
		$(gallery).each(function(i){
			$(this).hide();
			img[i] = [this.src,this.alt,$(this).attr('longdesc')];
			this.onload = function(){
				$(this).remove();
			}
			gallery[gallery.length-1].onload = function(){
				$(this).remove();
				start();
				started = true;
			}
			setTimeout(function(){
				if(!started) start();
			},2000)
		})
		function start(){
			
			// EDITABLE:
			$('body').prepend(galleryStructure); // DESTINATION OF GALLERY (YOU CAN CHANGE THIS)
			// --------
			
			$(img).each(function(i){
				$('#img-gallery ul').append('<li><a href="#img' + (i + 1) + '">' + (i + 1) + '</a></li>');
			})
			changeImage(0);
			$('#img-gallery ul a:not(#playstop)').click(function(){
				var imgToLoad = $(this).attr('href');
				imgToLoad = imgToLoad.split('#');
				imgToLoad = parseInt(imgToLoad[1].substr(3)) - 1;
				changeImage(imgToLoad);
				if(window['ssr']) $('#img-gallery ul a#playstop').click();
				return false;
			})
			$('#img-gallery ul a#playstop').toggle(function(){
				$(this).toggleClass('stop');
				startSlideShow();
				return false;
			}, function(){
				$(this).toggleClass('stop');
				stopSlideShow();
				return false;
			})
			function changeImage(n, callback){
				$('#img-gallery #img-description').fadeOut(speed / 5);
				$('#img-gallery img').fadeOut(speed / 4, function(){
					var originalWidth = $('#img-gallery img').width();
					$('#img-gallery img').attr('src', img[n][0]).attr('alt', img[n][1]);
					var width = $('#img-gallery img').width();
					var height = $('#img-gallery img').height();
					if (width == originalWidth) { fadeInAll(); } else { animate(); }
					function animate(){
						$('#img-gallery ul').fadeOut(speed / 2, function(){
							$('#img-gallery').animate({
								width: width,
								height: height
							}, speed / 2, function(){
								fadeInAll(true)
							})
						})
					}
					function fadeInAll(fromAnimate){
						var localSpeed = speed;
						if (!fromAnimate) 
							localSpeed = speed / 2;
						$('#img-gallery #img-description').html('<p>' + img[n][2] + '</p>');
						$('#img-gallery #img-description').fadeIn();
						$('#img-gallery img').fadeIn(localSpeed / 2);
						$('#img-gallery ul').fadeIn(localSpeed / 2);
						$('#img-gallery ul a:eq(' + (n + 1 - take) + ')').addClass('active');
						if (callback) callback();
						if (styling) styling();
					}
				})
				$('#img-gallery ul a').removeClass('active');
				
				if (img[n][2] == undefined) {
					$('#img-gallery #img-description').hide();
				}
				else {
					$('#img-gallery #img-description').show();
				}
			}
			function startSlideShow(){
				var imgToLoad = $('#img-gallery ul a.active:eq(0)').attr('href');
				imgToLoad = imgToLoad.split('#');
				window['ssr'] = true;
				imgToLoad = parseInt(imgToLoad[1].substr(3));
				if (imgToLoad == gallery.length) {
					imgToLoad = 0;
				}
				window['galleryTimeout'] = setTimeout(function(){
					startSlideShow()
				}, slideShowSpeed)
				changeImage(imgToLoad, function(){
					eval(galleryTimeout);
				});
			}
			function stopSlideShow(){
				window['ssr'] = false;
				clearTimeout(eval(galleryTimeout));
			}
		}
}