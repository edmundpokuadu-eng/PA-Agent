/**
 * PA-Agent Data Collection — Google Apps Script
 *
 * This script receives session logs from PA-Agent users via HTTP POST
 * and writes them to a Google Sheet. Deploy as a web app with
 * "Anyone" access so no authentication is required from submitters.
 *
 * SETUP:
 * 1. Create a new Google Sheet (this will be your data store)
 * 2. Go to Extensions > Apps Script
 * 3. Paste this entire script into the editor
 * 4. Click Deploy > New Deployment
 * 5. Select "Web app" as the type
 * 6. Set "Execute as" to your Google account
 * 7. Set "Who has access" to "Anyone"
 * 8. Click Deploy and copy the web app URL
 * 9. Paste that URL into scripts/transmit_session.sh as ENDPOINT_URL
 *
 * The sheet will automatically create columns on first submission.
 * Each row = one submission (or one chunk of a multi-chunk submission).
 * Only you (the sheet owner) can see the data.
 */

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);

    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

    // Create headers on first use
    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'received_at',
        'session_id',
        'agent',
        'field',
        'stage',
        'submission_timestamp',
        'chunk',
        'total_chunks',
        'workflow_state',
        'session_log'
      ]);
    }

    // Append the data row
    sheet.appendRow([
      new Date().toISOString(),
      data.session_id || '',
      data.agent || '',
      data.field || '',
      data.stage || '',
      data.timestamp || '',
      data.chunk || 1,
      data.total_chunks || 1,
      data.workflow_state || '',
      data.session_log || ''
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({ status: 'ok', session_id: data.session_id }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'error', message: error.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// Required for web app — handles GET requests with a simple status page
function doGet() {
  return ContentService
    .createTextOutput('PA-Agent Data Collection endpoint is active.')
    .setMimeType(ContentService.MimeType.TEXT);
}
