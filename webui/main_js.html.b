<script type="text/javascript">
   Shadowbox.init({
    players: ["qt"]
   });
function do_stuff(v){
 return "<img src='" + v + "' />";
}

 function launch(o){
  $.get("/launch/", {url:o.href});
 }

 function do_mouse(o){
 }

 $(document).ready(function(){
   $.fn.media.defaults.mp3Player = '/static_media/mediaplayer/player.swf';


   $(".open").click(function(){
    $.get("/launch/",{url:'"'+$(this).attr("href")+'"'});
    $.get("/most_recent/",{url:$(this).attr("href")});
    return false;
   });
 
   $("#q").james("/autocomplete/",{ 
    minlength:1
   });

   $("#q").keypress(function(e){
    if((e.which == 8) || ($(this).val().trim() == "")){
      $.get("/reset_autocomplete/",function(d){});
    }
   });

   $("#q").keypress(function(e){
   if((e.which == 13) || (e.keyCode == 13)){
   alert("dude");
   }
   //$.get("/query/q/", {q:$(#q).val()}, function(data){});
   //alert(data);
   //  return false;
   //}
   });

   $(".holder").mouseover(function(e){
     $(this).addClass("add_border");
     $(".tag_it", $(this)).toggle();
   }).mouseout(function(e){
     $(this).removeClass("add_border");
     $(".tag_it", $(this)).toggle();
   });

   $(".tag_it").toggle();


   $(".img").each(function(){
    var src = $("img",$(this)).attr("src");
    //src = src.replace(/\/images\//,"");
    $(this).attr("href",src);
   });
 
   $(".img").fancybox();

   $("#up").click(function(){
    $.scrollTo('#down', 1800 )
   });

   $("#down").click(function(){
    $.scrollTo('#super_up', 1800 )
   });


   $(".open").each(function(i){
     var href = $(this).attr("href")
     var split_char = '\\';
     var parts = href.split(split_char);
     var result = [];
     var last_result = "";
     for(var i in parts){
      last_result += parts[i];
      if(i < (parts.length - 1)){
       last_result += split_char;
      }
      result.push("<a href='" + last_result + "' class='url open' onmousemove='do_mouse(this);'  onclick='launch(this);return false;';>" + parts[i] + "</a>")
     }
     $(this).replaceWith(result.join(split_char));
   });

   $(".media").media({ width: 300, height: 20 });

 });
</script>
