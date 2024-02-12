import '../../models/protocol.dart';

String buildSeaScenarioXML(Scenario2 scenario) {
  final xml = StringBuffer();
  xml.writeln('<?xml version="1.0"?>');
  xml.writeln('<PropertyList>');
  xml.writeln('  <scenario>');
  xml.writeln('    <name>${scenario.scenarioName}</name>');
  xml.writeln('    <description>${scenario.description}</description>');
  xml.writeln('    <search-order>${scenario.searchOrder}</search-order>');
  xml.writeln('    <nasal>');
  xml.writeln('     <load>');
  xml.writeln('''        <![CDATA[
          var up = 1;
          var finish = 0;

          #foreach( var tanker; props.globals.getNode("/ai/models",1).getChildren("aircraft") ) {
          # tanker.getNode("orientation/pitch-deg", 1 ).setDoubleValue(0);
          #}

          var loop = func () {
            foreach( var tanker; props.globals.getNode("/ai/models",1).getChildren("aircraft") ) {
                var callsign = tanker.getNode("callsign").getValue();
                if( callsign == nil ) continue;
                if( string.match(callsign,"Evading*") or string.match(callsign,"Slow-evading*")
                    or string.match(callsign,"Fast-evading*") or string.match(callsign,"Very-fast-evading*")) {

                    var nodemode = tanker.getNode("controls/flight/vertical-mode", 1);
                    nodemode.setValue("alt");
                    var nodealt = tanker.getNode("controls/flight/target-alt", 1);
                  var node = tanker.getNode("position/altitude-ft", 1 );
                  var alt = node.getValue();
                  if(alt >= 11000) {
                    nodealt.setValue(8000);
                  } elsif (alt <= 7500) {
                    nodealt.setValue(8000);
                  } elsif (nodealt.getValue()==nil) {# or math.abs(nodealt.getValue()) != 35
                    nodealt.setValue(8000);
                  }
                  #alt = alt + 10*up;
                    #node.setDoubleValue(alt);

                  #var nodemode2 = tanker.getNode("controls/flight/lateral-mode", 1);
                  #nodemode2.setValue("roll");
                  #var noderoll = tanker.getNode("controls/flight/target-roll", 1);
                  # Get the current roll value
                  #var currentRoll = noderoll.getValue();
                  # Increment the current roll by 1
                  #var newRoll = currentRoll + 1;
                  # Set the new roll value
                  #noderoll.setValue(newRoll);
                  #tanker.getNode("rotors/main/blade[3]/position-deg", 1 ).setDoubleValue(rand());#chaff
                  #tanker.getNode("rotors/main/blade[3]/flap-deg", 1 ).setDoubleValue(rand());#flare
                }
              }
              if (finish == 0) {
                settimer(loop, 2);
              }
          }
          var loop2 = func () {
              foreach( var tanker; props.globals.getNode("/ai/models",1).getChildren("ship") ) {
                var lat = tanker.getNode("position/latitude-deg").getValue();
                var lon = tanker.getNode("position/longitude-deg").getValue();
                var node = tanker.getNode("position/altitude-ft", 1 );
                var alt = geo.elevation(lat, lon);
                node.setDoubleValue(alt==nil?0:alt*M2FT+1.5);
                var callsign = tanker.getNode("name").getValue();
                if( callsign == "Factory" ) continue;
                tanker.getNode("controls/tgt-speed-kts", 1).setDoubleValue(40); # hmm, this control seems to have changed in 2019.1?! Well works now.
              }
              if (finish == 0) {
                settimer(loop2, 0.05);
                return;
              }
              print("Scenario proper unloaded.");
              foreach( var tanker; props.globals.getNode("/ai/models",1).getChildren("ship") ) {
                var callsign = tanker.getNode("name").getValue();
                if( !string.match(callsign,"Humvee*") ) continue;
                tanker.remove(); # hmm, shouldn't be needed,  but is :(
              }
          }
          loop();
          loop2();
            debug.dump('Moving targets scenario load script complete');
        ]]>''');
  xml.writeln('     </load>');
  xml.writeln('     <unload>');
  xml.writeln('''        <![CDATA[
  finish = 1;

  ]]>''');
  xml.writeln('     </unload>');
  xml.writeln('    </nasal>');

  for (final entry in scenario.entries) {
    xml.writeln('    <entry>');
    xml.writeln('      <type>${entry.type}</type>');
    xml.writeln('      <model>${entry.model}</model>');
    xml.writeln('      <name>${entry.name}</name>');
    xml.writeln('      <latitude>${entry.latitude}</latitude>');
    xml.writeln('      <longitude>${entry.longitude}</longitude>');
    xml.writeln('      <speed>${entry.speed}</speed>');
    xml.writeln('      <rudder>${entry.rudder}</rudder>');
    xml.writeln('      <repeat>1</repeat>');
    xml.writeln('    </entry>');
  }

  xml.writeln('  </scenario>');
  xml.writeln('</PropertyList>');

  return xml.toString();
}
