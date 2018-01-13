<#setting time_zone="Europe/Vienna">
<#setting number_format="0.######">
<#if service??>
<#-- _______________________________ WMS _____________________________ -->
<#if service == "WMS">
  <#-------- PARAMETERS FOR WMS 1.1.1 AND 1.3.0 -->
    <#assign completemessage>${queryString}</#assign>
    <#assign layernamematch = queryString?matches("(?i)LAYERS=(.*?)(?:&|$)")>
    <#assign layername><#if layernamematch?size gt 0>${layernamematch[0]?groups[1]}<#else></#if></#assign>
    <#assign widthmatch = queryString?matches("(?i)&WIDTH=(.*?)(?:&|$)")>
    <#assign width><#if widthmatch?size gt 0>${widthmatch[0]?groups[1]}<#else></#if></#assign>
    <#assign heightmatch = queryString?matches("(?i)HEIGHT=(.*?)(?:&|$)")>
    <#assign height><#if heightmatch?size gt 0>${heightmatch[0]?groups[1]}<#else></#if></#assign>
    <#-------- PARAMETERS ONLY FOR WMS 1.1.1 -->
    <#if owsVersion == "1.1.1">
      <#assign x1match = queryString?matches("(?i)BBOX=(.*?),.*?(?:&|$)")>
      <#assign x1><#if x1match?size gt 0>${x1match[0]?groups[1]}<#else></#if></#assign>
      <#assign y1match = queryString?matches("(?i)BBOX=.*?,(.*?),.*?(?:&|$)")>
      <#assign y1><#if y1match?size gt 0>${y1match[0]?groups[1]}<#else></#if></#assign>
      <#assign x2match = queryString?matches("(?i)BBOX=.*?,.*?,(.*?),.*?(?:&|$)")>
      <#assign x2><#if x2match?size gt 0>${x2match[0]?groups[1]}<#else></#if></#assign>
      <#assign y2match = queryString?matches("(?i)BBOX=.*?,.*?,.*?,(.*?)(?:&|$)")>
      <#assign y2><#if y2match?size gt 0>${y2match[0]?groups[1]}<#else></#if></#assign>
      <#assign srsmatch = queryString?matches("(?i)SRS=(.*?)(?:&|$)")>
      <#assign srs><#if srsmatch?size gt 0>${srsmatch[0]?groups[1]}<#else></#if></#assign>
    <#elseif owsVersion == "1.3.0">
    <#-------- PARAMETERS ONLY FOR WMS 1.3.0 -->
      <#assign x1match = queryString?matches("(?i)BBOX=.*?,(.*?),.*?(?:&|$)")>
      <#assign x1><#if x1match?size gt 0>${x1match[0]?groups[1]}<#else></#if></#assign>
      <#assign y1match = queryString?matches("(?i)BBOX=(.*?),.*?(?:&|$)")>
      <#assign y1><#if y1match?size gt 0>${y1match[0]?groups[1]}<#else></#if></#assign>
      <#assign x2match = queryString?matches("(?i)BBOX=.*?,.*?,.*?,(.*?)(?:&|$)")>
      <#assign x2><#if x2match?size gt 0>${x2match[0]?groups[1]}<#else></#if></#assign>
      <#assign y2match = queryString?matches("(?i)BBOX=.*?,.*?,(.*?),.*?(?:&|$)")>
      <#assign y2><#if y2match?size gt 0>${y2match[0]?groups[1]}<#else></#if></#assign>
      <#assign srsmatch = queryString?matches("(?i)CRS=(.*?)(?:&|$)")>
      <#assign srs><#if srsmatch?size gt 0>${srsmatch[0]?groups[1]}<#else></#if></#assign>
	    </#if>
	<#-- ________________________________ WPS ______________________________-->
<#elseif service == "WPS">
  <#assign requestbody><@compress single_line=true>${bodyAsString}</@compress></#assign>
  <#assign completemessage>${requestbody}</#assign>
  <#assign layernamematch = requestbody?matches(r"layerName<.*?LiteralData>(.*?)<","i")>
  <#assign layername><#if layernamematch?size gt 0>${layernamematch[0]?groups[1]}<#else></#if></#assign>
  <#assign xymatch = requestbody?matches(r"POLYGON\s?\(\s?\(\s?(.*?)\s+(.*?)\s*,\s*(.*?)\s+.*?\s*,\s*.*?\s+(.*?)\s*,","i")>
  <#assign x1><#if xymatch?size gt 0>${xymatch[0]?groups[1]}<#else></#if></#assign>
  <#assign y1><#if xymatch?size gt 0>${xymatch[0]?groups[2]}<#else></#if></#assign>
  <#assign x2><#if xymatch?size gt 0>${xymatch[0]?groups[3]}<#else></#if></#assign>
  <#assign y2><#if xymatch?size gt 0>${xymatch[0]?groups[4]}<#else></#if></#assign>
  <#assign srsmatch = requestbody?matches(r"targetCRS<.*?LiteralData>(EPSG.*?)<","i")>
  <#assign srs><#if srsmatch?size gt 0>${srsmatch[0]?groups[1]}<#else></#if></#assign>
  <#assign heightmatch = requestbody?matches(r"targetSizeY<.*?LiteralData>(.*?)<","i")>
  <#assign height><#if heightmatch?size gt 0>${heightmatch[0]?groups[1]}<#elseif y1 != "" && y2 != ""><#if y1?number gt y2?number>${(y1?number - y2?number)*5}<#else>${(y2?number - y1?number)*5}</#if><#else></#if></#assign>
  <#assign widthmatch = requestbody?matches(r"targetSizeX<.*?LiteralData>(.*?)<","i")>
  <#assign width><#if widthmatch?size gt 0>${widthmatch[0]?groups[1]}<#elseif x1 != "" && x2 != ""><#if x1?number gt x2?number>${(x1?number - x2?number)*5}<#else>${(x2?number - x1?number)*5}</#if><#else></#if></#assign>
<#else>
<#-- ________________________________ UNBEKANNT ______________________________-->
</#if>
</#if>
<#-- _____________________________CALCULATIONS ___________________________-->
<#if x1??><#if x1 != ""><#if x1?number gt x2?number><#assign bboxwidth = x1?number - x2?number><#elseif x2?number gt x1?number><#assign bboxwidth = x2?number - x1?number></#if></#if></#if>
<#if bboxwidth??><#assign pixelsize = bboxwidth?number / width?number></#if>
${startTime?datetime?iso_local_ms}|${totalTime}|<#if error??>failed<#else>success</#if>|${host!""}|${responseContentType!""}|${responseLength?c}|${remoteAddr!""}|${service!""}|${owsVersion!""}|${operation!""}|${layername!""}|${width!""}|${height!""}|${pixelsize!""}|${srs!""}|${x1!""}|${y1!""}|${x2!""}|${y2!""}|${completemessage!""}
