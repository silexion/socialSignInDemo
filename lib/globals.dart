String role = "user";

String countryFromBArcode(String barcode, String type) {
  int n = int.parse(barcode.substring(0,3));
  var c = 'Magyarország';

  switch (n) {
    case 599: return 'Magyarország';
    case 858: return 'Szlovákia';
    case 590: return 'Lengyelország';
    case 594: return 'Románia';
    case 859: return 'Csehország';
    case 383: return 'Szlovénia';
    case 385: return 'Horvátország';
    case 387: return 'Bosznia-Hercegovina';
    case 389: return 'Montenegró';
    case 390: return 'Koszovó';
    case 470: return 'Kirgizisztán';
    case 471: return 'Tajvan';
    case 474: return 'Észtország';
    case 475: return 'Lettország';
    case 475: return 'Lettország';
    case 489: return 'Hongkong';
    default:
      if(n >= 400 && n <= 440) return 'Németország';
      if(n >= 500 && n <= 509) return 'Egyesült Királyság';
      if(n >= 960 && n <= 961) return 'Egyesült Királyság';
      if(n >= 450 && n <= 459) return 'Japán';
      if(n >= 460 && n <= 469) return 'Oroszország';
      if(n >= 690 && n <= 699) return 'Kína';
      if(n >= 868 && n <= 869) return 'Törökország';
      if(n >= 870 && n <= 879) return 'Hollandia';
      if(n >= 900 && n <= 919) return 'Ausztria';
      if(n >= 930 && n <= 939) return 'Ausztrália';
      if(n >= 754 && n <= 755) return 'Kanada';
      if(n >= 100 && n <= 139) return 'Amerikai Egyesült Államok';
      if(n >= 020 && n <= 029) return 'Amerikai Egyesült Államok';
      return '';
  }
}