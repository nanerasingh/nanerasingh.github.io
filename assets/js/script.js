$(".intro, .links > a, .btn, .links").css({opacity: 0});
$(".intro.cursor").hide();

if(window.location.host != "nanerasingh.com" && window.location.host != "www.nanerasingh.com") {
    window.location = "https://www.nanerasingh.com";
}

$(document).ready(function() {
    // Start typing animation
    var startText = $(".intro.start").text();
    var nameText = $(".intro.name").text();
    $(".intro.start").typewrite();
    $(".intro.name").typewrite({
        'wholeDelay': startText.length * 100
    });
    $(".intro.end").typewrite({
        'wholeDelay': (startText.length + nameText.length) * 100,
        'callback': function() {
            $(".links").animate({opacity: 1}, 250, function() {
                var count = 0
                $(".links > a").each(function(index) {
                    count++;
                    $(this).delay(index * 300).animate({opacity: 1}, 500);
                });
                var done = 300 * count;
                $(".btn").delay(done).animate({opacity: 1}, 500);
            });
        }
    });
    $(".intro").show().css({opacity: 1});
});
