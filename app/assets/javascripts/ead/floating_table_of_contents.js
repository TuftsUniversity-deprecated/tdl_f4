function handleTOC(eventObj) {
  var outermost = $('#outermost')
  var column = $('#floating_table_of_contents_column')
  var toc = $('#floating_table_of_contents')
  var window_left = $(window).scrollLeft();
  var window_top = $(window).scrollTop();
  var outermost_height = outermost.height();
  var toc_top = window_top - column.position().top;
  var toc_space = outermost.position().top + outermost_height - window_top;
  var toc_height = toc.height();
  var toc_at_top = (toc_top < 0);
  var toc_at_bottom = (toc_space < toc_height);

  if ((eventObj.type == "resize") || toc_at_top || toc_at_bottom) {
console.log("==========================================");
/*console.log("window_top is " + window_top);
console.log("outermost_height is " + outermost_height);
console.log("column.position().top is " + column.position().top);
console.log(">>> column.offset().top is " + column.offset().top);
console.log("toc_top is " + toc_top);
console.log("toc_space is " + toc_space);
console.log("toc_height is " + toc_height);*/
    // browser is resizing, or page is scrolled up or down to the point at which TOC should stick
    // to the top or bottom 
    toc.css('position', 'relative');
console.log("sticking left at 0px");
    toc.css('left', '0px');

    if (toc_at_top) {
      // TOC should be at top of column
      toc.css('top', '0px');
    } else if (toc_at_bottom) {
      // TOC should be at bottom of column
      toc.css('top', outermost_height - toc_height);
    } else {
      // resizing
      toc.css('top', toc_top);
    }
  } else {
    // TOC should float
console.log("------------------------------------------");
/*console.log("window_top is " + window_top);
console.log("outermost_height is " + outermost_height);
console.log("column.position().top is " + column.position().top);
console.log(">>> column.offset().top is " + column.offset().top);
console.log("toc_top is " + toc_top);
console.log("toc_space is " + toc_space);
console.log("toc_height is " + toc_height);*/
    toc.css('position', 'fixed');
    toc.css('left', column.offset().left - window_left);
console.log("floating -  column.offset().left is " + column.offset().left);
console.log("floating -  window_left is " + window_left);
console.log("floating -  column.offset().left - window_left is " + (column.offset().left - window_left));
    toc.css('top', '0px');
  }
}

$(window).scroll(handleTOC);
$(window).resize(handleTOC);
