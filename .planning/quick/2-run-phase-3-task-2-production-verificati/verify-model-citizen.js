const { chromium } = require('playwright');

async function verifyModelCitizen() {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  
  const results = {
    checks: [],
    passed: 0,
    failed: 0,
    na: 0
  };
  
  try {
    // Check 1: Site loads
    console.log('✓ Check 1: Loading https://athan-dial.github.io/model-citizen/');
    const response = await page.goto('https://athan-dial.github.io/model-citizen/', { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    const status = response.status();
    const check1 = { name: 'Site loads without errors', status: status === 200 ? 'PASS' : 'FAIL', details: `Status: ${status}` };
    results.checks.push(check1);
    if (check1.status === 'PASS') results.passed++; else results.failed++;
    console.log(`  Status: ${status} ${check1.status === 'PASS' ? '✓' : '✗'}`);
    
    // Check 2: Quartz branding present
    console.log('\n✓ Check 2: Verifying Quartz branding');
    const title = await page.title();
    const content = await page.content();
    const hasQuartz = content.includes('Quartz v4');
    const hasTitle = title.includes('Model Citizen');
    const check2 = { name: 'Quartz branding present', status: (hasQuartz && hasTitle) ? 'PASS' : 'FAIL', details: `Title: ${title}, Quartz: ${hasQuartz}` };
    results.checks.push(check2);
    if (check2.status === 'PASS') results.passed++; else results.failed++;
    console.log(`  Title: ${title} ${hasTitle ? '✓' : '✗'}`);
    console.log(`  Quartz v4: ${hasQuartz ? '✓' : '✗'}`);
    
    // Check 3: hello-world article accessible
    console.log('\n✓ Check 3: Checking hello-world article');
    const helloResponse = await page.goto('https://athan-dial.github.io/model-citizen/hello-world', {
      waitUntil: 'networkidle',
      timeout: 30000
    });
    const helloStatus = helloResponse.status();
    const check3 = { name: 'hello-world article accessible', status: helloStatus === 200 ? 'PASS' : 'FAIL', details: `Status: ${helloStatus}` };
    results.checks.push(check3);
    if (check3.status === 'PASS') results.passed++; else results.failed++;
    console.log(`  Status: ${helloStatus} ${check3.status === 'PASS' ? '✓' : '✗'}`);
    
    // Check 4: No 404 errors for assets
    console.log('\n✓ Check 4: Checking for asset errors');
    await page.goto('https://athan-dial.github.io/model-citizen/', { waitUntil: 'networkidle' });
    const networkRequests = [];
    page.on('response', response => {
      if (response.status() >= 400) {
        networkRequests.push({ url: response.url(), status: response.status() });
      }
    });
    await page.waitForTimeout(2000);
    const check4 = { name: 'No 404 errors for assets', status: networkRequests.length === 0 ? 'PASS' : 'FAIL', details: `Errors: ${networkRequests.length}` };
    results.checks.push(check4);
    if (check4.status === 'PASS') results.passed++; else results.failed++;
    console.log(`  Total errors (>=400): ${networkRequests.length} ${check4.status === 'PASS' ? '✓' : '✗'}`);
    
    // Check 5: Mobile responsive
    console.log('\n✓ Check 5: Testing mobile responsive layout');
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('https://athan-dial.github.io/model-citizen/', { waitUntil: 'networkidle' });
    const hasHorizontalScroll = await page.evaluate(() => {
      return document.documentElement.scrollWidth > document.documentElement.clientWidth;
    });
    const check5 = { name: 'Mobile responsive at 375px', status: !hasHorizontalScroll ? 'PASS' : 'FAIL', details: `No horizontal overflow: ${!hasHorizontalScroll}` };
    results.checks.push(check5);
    if (check5.status === 'PASS') results.passed++; else results.failed++;
    console.log(`  Viewport: 375x667`);
    console.log(`  No horizontal overflow: ${!hasHorizontalScroll ? '✓' : '✗'}`);
    
    // Summary
    console.log('\n============================================================');
    console.log('VERIFICATION SUMMARY');
    console.log('============================================================');
    console.log(`Total checks: ${results.checks.length}`);
    console.log(`Passed: ${results.passed} ✓`);
    console.log(`Failed: ${results.failed}`);
    console.log(`Overall: ${results.failed === 0 ? 'PASS ✓' : 'FAIL'}`);
    
  } catch (error) {
    console.error('Error during verification:', error.message);
    results.failed++;
  } finally {
    await browser.close();
  }
  
  return results;
}

verifyModelCitizen().then(results => {
  process.exit(results.failed > 0 ? 1 : 0);
});
