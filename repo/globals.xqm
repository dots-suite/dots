xquery version '3.0' ;

module namespace G = 'globals';
(:~
: Ce module regroupe les variables globales de DoTS
: @version 1
: @date 2023-07-06 
: @author École nationale des chartes - Philippe Pons
:)

declare default element namespace "https://github.com/dots-suite/dots";

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Variables pour le resolver 
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) 

declare variable $G:base_uri :=
  if (environment-variable("base_uri"))
  then environment-variable("base_uri")
  else substring-before(request:uri(), "/api");

(:~ Garantit un séparateur final. :)
declare %private function G:dir($path as xs:string) as xs:string {
  if (ends-with($path, "/") or ends-with($path, file:dir-separator()))
  then $path
  else concat($path, file:dir-separator())
};

(:~ Variable pour accéder aux feuilles de transformation XSLT :)
declare function G:linkToRenderer() as xs:string {
  let $custom := normalize-space(environment-variable("DOTS_RENDERERS_DIR"))
  return
    if ($custom = "")
    then concat(G:dir($G:webapp), "webapp/static/renderers/")
    else if (file:is-dir($custom))
    then G:dir($custom)
    else error(
      xs:QName("G:invalid-renderers-dir"),
      concat("DOTS_RENDERERS_DIR pointe vers un dossier inexistant : ", $custom)
    )
};

declare function G:linkToTransform() as xs:string {
  let $custom := normalize-space(environment-variable("DOTS_TRANSFORM_DIR"))
  return
    if ($custom = "")
    then concat(G:dir($G:webapp), "webapp/static/transform/")
    else if (file:is-dir($custom))
    then G:dir($custom)
    else error(
      xs:QName("G:invalid-transform-dir"),
      concat("DOTS_TRANSFORM_DIR pointe vers un dossier inexistant : ", $custom)
    )
};

declare function G:rendererConfig() as document-node() {
  let $config := concat(G:linkToRenderer(), "renderer_config.xml")
  return
    if (not(file:is-file($config)))
    then error(
      xs:QName("G:missing-renderer-config"),
      concat("renderer_config.xml introuvable : ", $config)
    )
    else
      try { doc(file:path-to-uri($config)) }
      catch * {
        error(
          xs:QName("G:invalid-renderer-config"),
          concat("renderer_config.xml illisible (", $config, ") : ", $err:description)
        )
      }
};

declare function G:rendererXslPath($renderer as element(renderer)) as xs:string {
  let $xsl := concat(
    G:linkToRenderer(),
    normalize-space($renderer/@name), "/",
    normalize-space($renderer/@path)
  )
  return
    if (file:is-file($xsl)) then $xsl
    else error(
      xs:QName("G:invalid-renderer-path"),
      concat("XSL du renderer « ", $renderer/@name, " » introuvable : ", $xsl)
    )
};

declare function G:defaultXslEnginePath() as xs:string {
  let $defaults := G:rendererConfig()//renderer[@mediaType = "html"][@default = "true"]
  return
    if (count($defaults) = 1)
    then G:rendererXslPath($defaults)
    else error(
      xs:QName("G:invalid-renderer-default"),
      concat("renderer_config.xml doit déclarer exactement un renderer html par défaut (trouvés : ",
             count($defaults), ")")
    )
};

(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Variables pour le DoTS Project Manager 
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) 

declare variable $G:dbSwitcher := "dots_db_switcher.xml";

declare variable $G:metadataMapping := "dots_default_metadata_mapping.xml";

(: Variable pour déclarer le séparateur utilisé pour les documents CSV. Attention: un seul séparateur possible commun à tous les documents CSV :)
declare variable $G:separator := "	";

(: Code langue de la langue principale du corpus pour indexation
: @todo: à conserver? utile?
: @todo: le rendre facultatif
:)
declare variable $G:language := "fr";




(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      Variables "transverses" 
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) 

(:~ Variable pour accéder au nom de la base de données dots :)
declare variable $G:dots := "dots";

declare variable $G:metadata := "metadata/";

(:~ Variable pour accéder au document "resources_register.xml" d'un projet :)
declare variable $G:resourcesRegister := "dots/resources_register.xml";

(:~ Variable pour accéder au registre (documentRegister)  qui liste les passages citables:)
declare variable $G:fragmentsRegister := "dots/fragments_register.xml";

(:~ This function allows retrieving the identifier ('topCollectionId') of a database based on its name.
: @param $dbName name of the database
: @return a string (identifier of a project)
:)
declare function G:getTopCollectionId($dbName as xs:string) {
  normalize-space(db:get($dbName, $G:resourcesRegister)//collection[not(@parentIds)]/@dtsResourceId)
};





(: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    Variables pour le module Validate (à reprendre)
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ :) 
   
declare variable $G:dbSwitchValidation := concat($G:webapp, "/schema/dots_db_switcher.rng");

declare variable $G:resourcesValidation := concat($G:webapp, "/schema/resources_register.rng");

declare variable $G:fragmentsValidation := concat($G:webapp, "/schema/fragments_register.rng");


(:~ Variable pour accéder au webapp :)
declare variable $G:webapp := file:parent(file:base-dir());
