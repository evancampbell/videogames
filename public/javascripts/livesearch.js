var currentSelection=0;
var currentName='';

$(function() {
  $('#searchfield').live('keydown',function(e) {
    switch(e.keyCode) {
      case 38:
        navigate('up');
      break;
      case 40:
        navigate('down');
      break;
      case 13:
        if (currentName!='') {
          $('#searchfield').val(currentName);
          $('#searchfield').blur();
          $('#recommend_form').submit();
          $('#recommend_submit').remove();
          $('#live_search_results').html('');
          $('#submit_container').html("<img src='images/loading.gif' width=40 />");
        }
      break;
    }
  });
  
  
  
  $('#live_search_results ul li a').live('hover',function() {
    currentSelection=$(this).data('number');
    setSelected(currentSelection);
  },function() {
    $('#live_search_results ul li a').removeClass('itemhover');
    currentName='';
  });
});


function navigate(direction) {
  if ($('.itemhover').size()==0) {
    currentSelection=-1;
  }
  if (direction=='up' && currentSelection!=-1) {
    if (currentSelection!=0) {
      currentSelection--;
    }
  } else if (direction=='down') {
    if (currentSelection != $('#live_search_results ul li').size()-1) {
      currentSelection++;
    }
  }
  setSelected(currentSelection);
}

function setSelected(menuitem) {
  $('#live_search_results ul li a').removeClass('itemhover').addClass('nothover');
  $('#live_search_results ul li a').eq(menuitem).removeClass('nothover').addClass('itemhover');
  currentName=$('#live_search_results ul li a').eq(menuitem).html();
}
