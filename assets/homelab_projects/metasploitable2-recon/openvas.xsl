<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>OpenVAS Report</title>
        <style>
          :root { color-scheme: light dark; }
          body{font-family:system-ui,Segoe UI,Arial;margin:16px;line-height:1.45}
          h1{margin:0 0 8px}
          .meta{color:#667;margin:0 0 12px}
          .summary{display:flex;gap:8px;flex-wrap:wrap;margin:12px 0 18px}
          .pill{border:1px solid #ccd;border-radius:999px;padding:4px 10px;background:#eef;font-size:13px}
          table{width:100%;border-collapse:collapse}
          th,td{padding:10px;border:1px solid #ccd;vertical-align:top}
          th{background:#eef;text-align:left}
          tr:nth-child(even){background:#f9fbff}
          .sev-High{color:#b00020;font-weight:700}
          .sev-Medium{color:#a34}
          .sev-Low{color:#555}
          small{color:#666}
        </style>
      </head>
      <body>
        <h1>OpenVAS Report</h1>
        <p class="meta">Rendered from XML via XSL (no PDF viewer required).</p>

        <!-- quick summary pills (host, totals, time) -->
        <div class="summary">
          <span class="pill"><b>Hosts:</b> <xsl:value-of select="//hosts/count"/></span>
          <span class="pill"><b>Total vulns (H/M/L):</b> <xsl:value-of select="//vulns/count"/></span>
          <span class="pill"><b>Scan start:</b> <xsl:value-of select="//scan_start"/></span>
          <span class="pill"><b>Timezone:</b> <xsl:value-of select="//timezone_abbrev"/></span>
        </div>

        <table>
          <thead>
            <tr>
              <th style="width:45%">Finding</th>
              <th style="width:20%">Host:Port</th>
              <th style="width:15%">Severity</th>
              <th style="width:20%">CVEs</th>
            </tr>
          </thead>
          <tbody>
            <!-- Each vulnerability/result row -->
            <xsl:for-each select="//results/result">
              <tr>
                <td>
                  <strong><xsl:value-of select="name"/></strong><br/>
                  <small><xsl:value-of select="normalize-space(nvt/@oid)"/></small>
                  <xsl:if test="string(description)">
                    <br/><small><xsl:value-of select="description"/></small>
                  </xsl:if>
                </td>
                <td>
                  <xsl:value-of select="host"/>
                  <xsl:if test="string(port)">:<xsl:value-of select="port"/></xsl:if>
                </td>
                <td class="sev-{normalize-space(threat)}">
                  <xsl:value-of select="threat"/>
                  <xsl:if test="string(severity)">
                    <xsl:text> (</xsl:text><xsl:value-of select="severity"/><xsl:text>)</xsl:text>
                  </xsl:if>
                </td>
                <td>
                  <!-- Prefer nvt/cve; fall back to refs of type 'cve' -->
                  <xsl:choose>
                    <xsl:when test="normalize-space(nvt/cve)">
                      <xsl:value-of select="normalize-space(nvt/cve)"/>
                    </xsl:when>
                    <xsl:when test="nvt/refs/ref[@type='cve']">
                      <xsl:for-each select="nvt/refs/ref[@type='cve']">
                        <xsl:value-of select="@id"/><xsl:if test="position()!=last()">, </xsl:if>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>—</xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
