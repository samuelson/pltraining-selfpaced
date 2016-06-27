//Wait for page to load before we use jQuery
document.addEventListener('DOMContentLoaded', function(){ 

$(document).ready(function(){
  
  // Clean up some default styling
  $('#banner').css({"visibility":"hidden", "height":"0"});
  $('#user-content > .content').removeClass("container");
  $('#user-content > .content').addClass("container-fluid");
    
  $('#video > iframe').width($('#instructions').width());
  $('#video > iframe').height(($('#instructions').width() * 9) / 16);

  $( window ).resize(function () {
    
    var visibleHeight = $(window).height() - $('#content').offset()['top'] - $('#pathway-footer').height() + 10;
    $('#instructions').height(visibleHeight);
    $('#right').height(visibleHeight);
    $('#video > iframe').width($('#instructions').width());
    $('#video > iframe').height(($('#instructions').width() * 9) / 16);

  });

});

}, false);  
