<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>OpenVAS Report</title>
        <style>
          :root{
            color-scheme: light dark;
            /* Dark theme defaults */
            --bg:#0b0f17; --text:#e6eaf2; --muted:#9aa4b2;
            --card:#121826; --border:#1e293b; --header:#161d2b;
            --chip-bg:#0f172a; --chip-border:#263244; --chip-text:#d6dce6;
            --row:#0f1623; --row-alt:#0c1320;
            --sev-high:#ef4444; --sev-high-bg:rgba(239,68,68,.15); --sev-high-br:#7f1d1d;
            --sev-med:#f59e0b; --sev-med-bg:rgba(245,158,11,.15);  --sev-med-br:#7c4405;
            --sev-low:#10b981; --sev-low-bg:rgba(16,185,129,.15); --sev-low-br:#0b624a;
          }
          @media (prefers-color-scheme: light){
            :root{
              --bg:#ffffff; --text:#0f172a; --muted:#475569;
              --card:#ffffff; --border:#e2e8f0; --header:#f1f5f9;
              --chip-bg:#f8fafc; --chip-border:#e2e8f0; --chip-text:#0f172a;
              --row:#ffffff; --row-alt:#f9fbff;
            }
          }

          html,body{background:var(--bg);color:var(--text);font-family:system-ui,Segoe UI,Arial,sans-serif;line-height:1.45;margin:0}
          .container{max-width:1100px;margin:16px auto;padding:0 12px}
          h1{margin:0 0 6px;font-size:32px}
          .meta{color:var(--muted);margin:0 0 14px}

          .summary{display:flex;gap:8px;flex-wrap:wrap;margin:12px 0 18px}
          .pill{border:1px solid var(--chip-border);border-radius:999px;padding:6px 10px;background:var(--chip-bg);color:var(--chip-text);font-size:13px}

          .table-wrap{border:1px solid var(--border);border-radius:12px;overflow:hidden;background:var(--card)}
          table{width:100%;border-collapse:separate;border-spacing:0}
          th,td{padding:12px 14px;border-bottom:1px solid var(--border);vertical-align:top}
          thead th{position:sticky;top:0;background:var(--header);z-index:1;text-align:left;font-weight:600}
          tbody tr:nth-child(even){background:var(--row-alt)}
          tbody tr:nth-child(odd){background:var(--row)}
          small{color:var(--muted)}
          code,kbd,pre{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}

          .severity-badge{
            display:inline-block;font-weight:700;font-size:12px;border-radius:999px;padding:4px 8px;border:1px solid;
          }
          .sev-High{color:var(--sev-high);background:var(--sev-high-bg);border-color:var(--sev-high-br)}
          .sev-Medium{color:var(--sev-med);background:var(--sev-med-bg);border-color:var(--sev-med-br)}
          .sev-Low{color:var(--sev-low);background:var(--sev-low-bg);border-color:var(--sev-low-br)}

          details{margin-top:6px}
          details > summary{cursor:pointer;color:var(--muted);outline:none}
          details[open] > summary{color:var(--text)}
          .desc{white-space:pre-wrap;font-size:13px;color:var(--text);margin-top:6px}
        </style>
      </head>
      <body>
        <div class="container">
          <h1>OpenVAS Report</h1>
          <p class="meta">Rendered from XML via XSL.</p>

          <div class="summary">
            <span class="pill"><b>Hosts:</b> <xsl:value-of select="//hosts/count"/></span>
            <span class="pill"><b>Total vulns (H/M/L):</b> <xsl:value-of select="//vulns/count"/></span>
            <span class="pill"><b>Scan start:</b> <xsl:value-of select="//scan_start"/></span>
            <span class="pill"><b>Timezone:</b> <xsl:value-of select="//timezone_abbrev"/></span>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th style="width:46%">Finding</th>
                  <th style="width:22%">Host:Port</th>
                  <th style="width:16%">Severity</th>
                  <th style="width:16%">CVEs</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//results/result">
                  <tr>
                    <td>
                      <strong><xsl:value-of select="name"/></strong><br/>
                      <small>OID: <xsl:value-of select="normalize-space(nvt/@oid)"/></small>

                      <xsl:if test="string(description)">
                        <details>
                          <summary>Details</summary>
                          <div class="desc"><xsl:value-of select="description"/></div>
                        </details>
                      </xsl:if>
                    </td>

                    <td>
                      <code><xsl:value-of select="host"/></code>
                      <xsl:if test="string(port)">
                        <xsl:text>:</xsl:text><code><xsl:value-of select="port"/></code>
                      </xsl:if>
                    </td>

                    <td>
                      <span class="severity-badge sev-{normalize-space(threat)}">
                        <xsl:value-of select="threat"/>
                        <xsl:if test="string(severity)">
                          <xsl:text> (</xsl:text><xsl:value-of select="format-number(number(severity),'0.0')"/><xsl:text>)</xsl:text>
                        </xsl:if>
                      </span>
                    </td>

                    <td>
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
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
