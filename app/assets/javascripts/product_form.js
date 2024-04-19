// app/assets/javascripts/product_form.js

document.addEventListener('turbolinks:load', function() {
  var sizeInput = document.querySelector('.size-input');

  if (sizeInput) {
    sizeInput.addEventListener('change', function() {
      var sizeValue = sizeInput.value;
      // Splitting the value into numeric and unit parts
      var parts = sizeValue.split(' ');

      // If both numeric and unit parts are present
      if (parts.length === 2) {
        var numericValue = parts[0];
        var unitValue = parts[1];
        // Do something with numericValue and unitValue
        console.log('Numeric Value:', numericValue);
        console.log('Unit Value:', unitValue);
      } else {
        // Handle invalid input format
        console.error('Invalid input format for size');
      }
    });
  }
});
