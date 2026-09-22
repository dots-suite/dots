# HTML / TXT Renderer — TEI Consortium Stylesheets

This renderer produces HTML and plain-text output from TEI documents using the official [TEI Consortium Stylesheets](https://github.com/TEIC/Stylesheets).

## Setup

1. **Clone the TEI Consortium Stylesheets** into this folder (the same folder as this README):
   
   ```
   git clone https://github.com/TEIC/Stylesheets.git
   ```

2. **Enable the configuration file**, if not already done. DoTS ships a template, `renderer_config_template.xml`, which is version-controlled but not active by default. Copy or rename it to `renderer_config.xml` (untracked) in the renderer configuration directory:
   
   ```
   cp renderer_config_template.xml renderer_config.xml
   ```

3. **Uncomment the two corresponding lines** in `renderer_config.xml` to enable HTML and TXT output:

```xml
<dots:renderer name="teic" mediaType="html" path="teic_html.xsl" default="true"/> 

<dots:renderer name="teic" mediaType="txt" path="Stylesheets/txt/tei-to-text.xsl" default="true"/> 
```

## That's it

Once the `Stylesheets` repository is cloned here, `renderer_config.xml` exists, and the relevant renderer lines are uncommented, HTML and TXT output are picked up automatically — no further configuration is needed.
