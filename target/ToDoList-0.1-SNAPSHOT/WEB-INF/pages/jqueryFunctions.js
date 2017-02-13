
$(document).ready(function(){
  $('#list_info input.move').click(function() {
      var row = $(this).closest('tr');
      if ($(this).hasClass('up'))
          row.prev().before(row);
      else
          row.next().after(row);
  });
});

