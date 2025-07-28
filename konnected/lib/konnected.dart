import 'package:teledart/model.dart';

List<KeyboardButton> buildKeyboardButton(String text) =>
    [KeyboardButton(text: text)];
List<KeyboardButton> mainMenuButton() =>
    [KeyboardButton(text: "Main Menu 🎛  [/main]")];

List<List<KeyboardButton>> giveCountriesInRegion(String message, bool isSetup) {
  final command = isSetup ? "/changecountry" : "/setprofilecountry";
  if (message.endsWith("na]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇺🇸 United States [$command Usa]"),
      buildKeyboardButton("🇨🇦 Canada [$command Canada]"),
      buildKeyboardButton("🇲🇽 Mexico [$command Mexico]"),
      buildKeyboardButton("🇵🇷 Puerto Rico [$command Puerto Rico]"),
      buildKeyboardButton("🇬🇹 Guatemala [$command Guatemala]"),
      buildKeyboardButton("🇭🇹 Haiti [$command Haiti]"),
      buildKeyboardButton(
          "🇩🇴 Dominican Republic [$command Dominican Republic]"),
      buildKeyboardButton("🇨🇺 Cuba [$command Cuba]"),
      buildKeyboardButton("🇭🇳 Honduras [$command Honduras]"),
      buildKeyboardButton("🇳🇮 Nicaragua [$command Nicaragua]"),
      buildKeyboardButton("🇸🇻 El Salvador [$command El Salvador]"),
      buildKeyboardButton("🇨🇷 Costa Rica [$command Costa Rica]"),
      buildKeyboardButton("🇵🇦 Panama [$command Panama]"),
      buildKeyboardButton("🇯🇲 Jamaica [$command Jamaica]"),
      buildKeyboardButton(
          "🇹🇹 Trinidad and Tobago [$command Trinidad and Tobago]"),
      buildKeyboardButton("🇧🇸 Bahamas [$command Bahamas]"),
      buildKeyboardButton("🇧🇿 Belize [$command Belize]"),
      buildKeyboardButton("Saint Lucia [$command Saint Lucia]"),
      buildKeyboardButton("🇬🇩 Grenada [$command Grenada]"),
      buildKeyboardButton(
          "Saint Vincent and the Grenadines [$command Saint Vincent and the Grenadines]"),
      buildKeyboardButton(
          "🇦🇬 Antigua and Barbuda [$command Antigua and Barbuda]"),
      buildKeyboardButton("🇩🇲 Dominica [$command Dominica]"),
      buildKeyboardButton(
          "Saint Kitts and Nevis [$command Saint Kitts and Nevis]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("sa]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇧🇷 Brazil [$command Brazil]"),
      buildKeyboardButton("🇨🇴 Colombia [$command Colombia]"),
      buildKeyboardButton("🇦🇷 Argentina [$command Argentina]"),
      buildKeyboardButton("🇵🇪 Peru [$command Peru]"),
      buildKeyboardButton("🇻🇪 Venezuela [$command Venezuela]"),
      buildKeyboardButton("🇨🇱 Chile [$command Chile]"),
      buildKeyboardButton("🇪🇨 Ecuador [$command Ecuador]"),
      buildKeyboardButton("🇧🇴 Bolivia [$command Bolivia]"),
      buildKeyboardButton("🇵🇾 Paraguay [$command Paraguay]"),
      buildKeyboardButton("🇺🇾 Uruguay [$command Uruguay]"),
      buildKeyboardButton("🇬🇾 Guya na [$command Guyana]"),
      buildKeyboardButton("🇸🇷 Suriname [/chang ec ountry Suriname]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("eu]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇷🇺 Russia [$command Russia]"),
      buildKeyboardButton("🇹🇷 Turkey [$command Turkey]"),
      buildKeyboardButton("🇩🇪 Germany [$command Germany]"),
      buildKeyboardButton(
          "🇬🇧 United Kingdom [$command United Kingdom]"),
      buildKeyboardButton("🇫🇷 France [$command France]"),
      buildKeyboardButton("🇮🇹 Italy [$command Italy]"),
      buildKeyboardButton("🇪🇸 Spain [$command Spain]"),
      buildKeyboardButton("🇺🇦 Ukraine [$command Ukraine]"),
      buildKeyboardButton("🇵🇱 Poland [$command Poland]"),
      buildKeyboardButton("🇰🇿 Kazakhstan [$command Kazakhstan]"),
      buildKeyboardButton("🇷🇴 Romania [$command Romania]"),
      buildKeyboardButton("🇳🇱 Netherlands [$command Netherlands]"),
      buildKeyboardButton("🇧🇪 Belgium [$command Belgium]"),
      buildKeyboardButton("🇸🇪 Sweden [$command Sweden]"),
      buildKeyboardButton(
          "🇨🇿 Czech Republic [$command Czech Republic]"),
      buildKeyboardButton("🇵🇹 Portugal [$command Portugal]"),
      buildKeyboardButton("🇦🇿 Azerbaijan [$command Azerbaijan]"),
      buildKeyboardButton("🇬🇷 Greece [$command Greece]"),
      buildKeyboardButton("🇭🇺 Hungary [$command Hungary]"),
      buildKeyboardButton("🇦🇹 Austria [$command Austria]"),
      buildKeyboardButton("🇧🇾 Belarus [$command Belarus]"),
      buildKeyboardButton("🇨🇭 Switzerland [$command Switzerland]"),
      buildKeyboardButton("🇧🇬 Bulgaria [$command Bulgaria]"),
      buildKeyboardButton("🇷🇸 Serbia [$command Serbia]"),
      buildKeyboardButton("🇩🇰 Denmark [$command Denmark]"),
      buildKeyboardButton("🇫🇮 Finland [$command Finland]"),
      buildKeyboardButton("🇳🇴 Norway [$command Norway]"),
      buildKeyboardButton("🇸🇰 Slovakia [$command Slovakia]"),
      buildKeyboardButton("🇮🇪 Ireland [$command Ireland]"),
      buildKeyboardButton("🇭🇷 Croatia [$command Croatia]"),
      buildKeyboardButton("🇬🇪 Georgia [$command Georgia]"),
      buildKeyboardButton(
          "🇧🇦 Bosnia and Herzegovina [$command Bosnia and Herzegovina]"),
      buildKeyboardButton("🇲🇩 Moldova [$command Moldova]"),
      buildKeyboardButton("🇦🇲 Armenia [$command Armenia]"),
      buildKeyboardButton("🇱🇹 Lithuania [$command Lithuania]"),
      buildKeyboardButton("🇦🇱 Albania [$command Albania]"),
      buildKeyboardButton("🇸🇮 Slovenia [$command Slovenia]"),
      buildKeyboardButton(
          "🇲🇰 North Macedonia [$command North Macedonia]"),
      buildKeyboardButton("🇽🇰 Kosovo [$command Kosovo]"),
      buildKeyboardButton("🇨🇾 Cyprus [$command Cyprus]"),
      buildKeyboardButton("🇪🇪 Estonia [$command Estonia]"),
      buildKeyboardButton("🇱🇺 Luxembourg [$command Luxembourg]"),
      buildKeyboardButton("🇲🇪 Montenegro [$command Montenegro]"),
      buildKeyboardButton("🇲🇹 Malta [$command Malta]"),
      buildKeyboardButton("🇮🇸 Iceland [$command Iceland]"),
      buildKeyboardButton("🇦🇩 Andorra [$command Andorra]"),
      buildKeyboardButton("🇱🇮 Liechtenstein [$command Liechtenstein]"),
      buildKeyboardButton("🇲🇨 Monaco [$command Monaco]"),
      buildKeyboardButton("🇸🇲 San Marino [$command San Marino]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("MENA]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇪🇬 Egypt [$command Egypt]"),
      buildKeyboardButton("🇮🇷 Iran [$command Iran]"),
      buildKeyboardButton("🇮🇶 Iraq [$command Iraq]"),
      buildKeyboardButton("🇸🇦 Saudi Arabia [$command Saudi Arabia]"),
      buildKeyboardButton("🇾🇪 Yemen [$command Yemen]"),
      buildKeyboardButton("🇸🇾 Syria [$command Syria]"),
      buildKeyboardButton("🇯🇴 Jordan [$command Jordan]"),
      buildKeyboardButton(
          "🇦🇪 United Arab Emirates [$command United Arab Emirates]"),
      buildKeyboardButton("🇱🇧 Lebanon [$command Lebanon]"),
      buildKeyboardButton("Palestine [$command Palestine]"),
      buildKeyboardButton("🇴🇲 Oman [$command Oman]"),
      buildKeyboardButton("🇰🇼 Kuwait [$command Kuwait]"),
      buildKeyboardButton("🇶🇦 Qatar [$command Qatar]"),
      buildKeyboardButton("🇧🇭 Bahrain [$command Bahrain]"),
      buildKeyboardButton("🇱🇾 Libya [$command Libya]"),
      buildKeyboardButton("🇩🇿 Algeria [$command Algeria]"),
      buildKeyboardButton("🇹🇳 Tunisia [$command Tunisia]"),
      buildKeyboardButton("🇲🇦 Morocco [$command Morocco]"),
      buildKeyboardButton("Israel [$command Israel]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("af]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇳🇬 Nigeria [$command Nigeria]"),
      buildKeyboardButton("🇪🇹 Ethiopia [$command Ethiopia]"),
      buildKeyboardButton("🇨🇩 DR Congo [$command DR Congo]"),
      buildKeyboardButton("🇹🇿 Tanzania [$command Tanzania]"),
      buildKeyboardButton("🇿🇦 South Africa [$command South Africa]"),
      buildKeyboardButton("🇰🇪 Kenya [$command Kenya]"),
      buildKeyboardButton("🇸🇩 Sudan [$command Sudan]"),
      buildKeyboardButton("🇺🇬 Uganda [$command Uganda]"),
      buildKeyboardButton("🇦🇴 Angola [$command Angola]"),
      buildKeyboardButton("🇬🇭 Ghana [$command Ghana]"),
      buildKeyboardButton("🇲🇿 Mozambique [$command Mozambique]"),
      buildKeyboardButton("🇲🇬 Madagascar [$command Madagascar]"),
      buildKeyboardButton("🇨🇮 Ivory Coast [$command Ivory Coast]"),
      buildKeyboardButton("🇨🇲 Cameroon [$command Cameroon]"),
      buildKeyboardButton("🇳🇪 Niger [$command Niger]"),
      buildKeyboardButton("🇲🇱 Mali [$command Mali]"),
      buildKeyboardButton("🇧🇫 Burkina Faso [$command Burkina Faso]"),
      buildKeyboardButton("🇲🇼 Malawi [$command Malawi]"),
      buildKeyboardButton("🇿🇲 Zambia [$command Zambia]"),
      buildKeyboardButton("🇹🇩 Chad [$command Chad]"),
      buildKeyboardButton("🇸🇴 Somalia [$command Somalia]"),
      buildKeyboardButton("🇸🇳 Senegal [$command Senegal]"),
      buildKeyboardButton("🇿🇼 Zimbabwe [$command Zimbabwe]"),
      buildKeyboardButton("🇬🇳 Guinea [$command Guinea]"),
      buildKeyboardButton("🇧🇯 Benin [$command Benin]"),
      buildKeyboardButton("🇷🇼 Rwanda [$command Rwanda]"),
      buildKeyboardButton("🇧🇮 Burundi [$command Burundi]"),
      buildKeyboardButton("🇸🇸 South Sudan [$command South Sudan]"),
      buildKeyboardButton("🇹🇬 Togo [$command Togo]"),
      buildKeyboardButton("🇸🇱 Sierra Leone [$command Sierra Leone]"),
      buildKeyboardButton(
          "🇨🇬 Republic of the Congo [$command Republic of the Congo]"),
      buildKeyboardButton("🇱🇷 Liberia [$command Liberia]"),
      buildKeyboardButton(
          "🇨🇫 Central African Republic [$command Central African Republic]"),
      buildKeyboardButton("🇲🇷 Mauritania [$command Mauritania]"),
      buildKeyboardButton("🇪🇷 Eritrea [$command Eritrea]"),
      buildKeyboardButton("🇳🇦 Namibia [$command Namibia]"),
      buildKeyboardButton("🇬🇲 Gambia [$command Gambia]"),
      buildKeyboardButton("🇬🇦 Gabon [$command Gabon]"),
      buildKeyboardButton("🇧🇼 Botswana [$command Botswana]"),
      buildKeyboardButton("🇱🇸 Lesotho [$command Lesotho]"),
      buildKeyboardButton("🇬🇼 Guinea-Bissau [$command Guinea-Bissau]"),
      buildKeyboardButton(
          "🇬🇶 Equatorial Guinea [$command Equatorial Guinea]"),
      buildKeyboardButton("🇲🇺 Mauritius [$command Mauritius]"),
      buildKeyboardButton("🇸🇿 Eswatini [$command Eswatini]"),
      buildKeyboardButton("🇩🇯 Djibouti [$command Djibouti]"),
      buildKeyboardButton("🇷🇪 Réunion [$command Réunion]"),
      buildKeyboardButton("🇰🇲 Comoros [$command Comoros]"),
      buildKeyboardButton("🇨🇻 Cape Verde [$command Cape Verde]"),
      buildKeyboardButton(
          "🇸🇹 São Tomé and Príncipe [$command São Tomé and Príncipe]"),
      buildKeyboardButton("🇸🇨 Seychelles [$command Seychelles]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("as]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇮🇳 India [$command India]"),
      buildKeyboardButton("🇨🇳 China [$command China]"),
      buildKeyboardButton("🇮🇩 Indonesia [$command Indonesia]"),
      buildKeyboardButton("🇵🇰 Pakistan [$command Pakistan]"),
      buildKeyboardButton("🇧🇩 Bangladesh [$command Bangladesh]"),
      buildKeyboardButton("🇯🇵 Japan [$command Japan]"),
      buildKeyboardButton("🇵🇭 Philippines [$command Philippines]"),
      buildKeyboardButton("🇻🇳 Vietnam [$command Vietnam]"),
      buildKeyboardButton("🇹🇭 Thailand [$command Thailand]"),
      buildKeyboardButton("🇲🇲 Myanmar [$command Myanmar]"),
      buildKeyboardButton("🇰🇷 South Korea [$command South Korea]"),
      buildKeyboardButton("🇦🇫 Afghanistan [$command Afghanistan]"),
      buildKeyboardButton("🇺🇿 Uzbekistan [$command Uzbekistan]"),
      buildKeyboardButton("🇲🇾 Malaysia [$command Malaysia]"),
      buildKeyboardButton("🇳🇵 Nepal [$command Nepal]"),
      buildKeyboardButton("🇰🇵 North Korea [$command North Korea]"),
      buildKeyboardButton("🇹🇼 Taiwan [$command Taiwan]"),
      buildKeyboardButton("🇱🇰 Sri Lanka [$command Sri Lanka]"),
      buildKeyboardButton("🇰🇭 Cambodia [$command Cambodia]"),
      buildKeyboardButton("🇹🇯 Tajikistan [$command Tajikistan]"),
      buildKeyboardButton("🇱🇦 Laos [$command Laos]"),
      buildKeyboardButton("🇭🇰 Hong Kong [$command Hong Kong]"),
      buildKeyboardButton("🇰🇬 Kyrgyzstan [$command Kyrgyzstan]"),
      buildKeyboardButton("🇹🇲 Turkmenistan [$command Turkmenistan]"),
      buildKeyboardButton("🇸🇬 Singapore [$command Singapore]"),
      buildKeyboardButton("🇲🇳 Mongolia [$command Mongolia]"),
      buildKeyboardButton("🇧🇹 Bhutan [$command Bhutan]"),
      buildKeyboardButton("🇹🇱 Timor-Leste [$command Timor-Leste]"),
      buildKeyboardButton("Macau [$command Macau]"),
      buildKeyboardButton("🇲🇻 Maldives [$command Maldives]"),
      buildKeyboardButton("🇧🇳 Brunei [$command Brunei]"),
      mainMenuButton(),
    ];
  }
  if (message.endsWith("oc]")) {
    return [
      mainMenuButton(),
      buildKeyboardButton("🇦🇺 Australia [$command Australia]"),
      buildKeyboardButton(
          "🇵🇬 Papua New Guinea [$command Papua New Guinea]"),
      buildKeyboardButton("🇳🇿 New Zealand [$command New Zealand]"),
      buildKeyboardButton("🇫🇯 Fiji [$command Fiji]"),
      buildKeyboardButton(
          "🇸🇧 Solomon Islands [$command Solomon Islands]"),
      buildKeyboardButton("🇻🇺 Vanuatu [$command Vanuatu]"),
      buildKeyboardButton("🇼🇸 Samoa [$command Samoa]"),
      buildKeyboardButton("🇰🇮 Kiribati [$command Kiribati]"),
      buildKeyboardButton("🇫🇲 Micronesia [$command Micronesia]"),
      buildKeyboardButton("🇹🇴 Tonga [$command Tonga]"),
      buildKeyboardButton(
          "🇲🇭 Marshall Islands [$command Marshall Islands]"),
      buildKeyboardButton("🇵🇼 Palau [$command Palau]"),
      buildKeyboardButton("🇳🇷 Nauru [$command Nauru]"),
      buildKeyboardButton("🇹🇻 Tuvalu [$command Tuvalu]"),
      mainMenuButton(),
    ];
  }
  return [];
}
