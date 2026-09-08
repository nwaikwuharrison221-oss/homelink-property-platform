class PriceInWords {
  static String convert(int number) {
    if (number == 0) return "Zero Naira per Year";

    final ones = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen"
    ];

    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety"
    ];

    String convertLessThan1000(int n) {
      String words = "";

      if (n >= 100) {
        words += "${ones[n ~/ 100]} Hundred";
        n %= 100;
        if (n > 0) words += " ";
      }

      if (n >= 20) {
        words += tens[n ~/ 10];
        if (n % 10 > 0) {
          words += " ${ones[n % 10]}";
        }
      } else if (n > 0) {
        words += ones[n];
      }

      return words;
    }

    String result = "";

    if (number >= 1000000) {
      result += "${convertLessThan1000(number ~/ 1000000)} Million ";
      number %= 1000000;
    }

    if (number >= 1000) {
      result += "${convertLessThan1000(number ~/ 1000)} Thousand ";
      number %= 1000;
    }

    if (number > 0) {
      result += convertLessThan1000(number);
    }

    return "${result.trim()} Naira per Year";
  }
}