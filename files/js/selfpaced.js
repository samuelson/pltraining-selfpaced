$.when(
  $.getScript( "https://cdnjs.cloudflare.com/ajax/libs/jquery-countdown/2.0.2/jquery.plugin.min.js"),
  $.getScript( "https://cdnjs.cloudflare.com/ajax/libs/js-cookie/2.1.3/js.cookie.min.js" ),
  $.getScript( "https://cdnjs.cloudflare.com/ajax/libs/node-uuid/1.4.7/uuid.min.js" ),
  $.Deferred(function( deferred ){
    $( deferred.resolve);
  })
).done(function(){
  var course_name = $(".navigation-learning-name").text().replace(/\s/g, '-');

  if (Cookies.get(course_name + "-uuid")) {
    var student_uuid = Cookies.get(course_name + "-uuid")
  } else {
    var student_uuid = uuid();
    Cookies.set(course_name + "-uuid", student_uuid);
  }

  var url = $("#try").attr( "src" );
  $("#try").attr( "src", url + "&uuid=" + student_uuid );
});
