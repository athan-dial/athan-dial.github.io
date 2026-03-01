const { chromium } = require('playwright');

async function verifyDeployment() {
  const results = {
    timestamp: new Date().toISOString(),
    url: 'https://athan-dial.github.io/',
    checks: []
  };

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 }
  });
  const page = await context.newPage();

  // Collect console messages
  const consoleMessages = [];
  page.on('console', msg => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text()
    });
  });

  // Collect network requests
  const networkRequests = [];
  page.on('response', response => {
    networkRequests.push({
      url: response.url(),
      status: response.status(),
      statusText: response.statusText()
    });
  });

  try {
    // Check 1: Navigate to production site
    console.log('✓ Check 1: Navigating to https://athan-dial.github.io/');
    const response = await page.goto('https://athan-dial.github.io/', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    const statusCode = response.status();
    results.checks.push({
      name: 'Site loads without errors',
      status: statusCode === 200 ? 'PASS' : 'FAIL',
      details: `Status code: ${statusCode}`,
      expected: '200',
      actual: statusCode.toString()
    });
    console.log(`  Status: ${statusCode} ${statusCode === 200 ? '✓' : '✗'}`);

    // Wait a bit for page to fully load
    await page.waitForTimeout(2000);

    // Check 2: Verify page content loads
    console.log('\n✓ Check 2: Verifying page content loads');
    const bodyText = await page.textContent('body');
    const hasErrorText = bodyText.includes('404') || bodyText.includes('Not Found') || bodyText.includes('Error');
    const hasContent = bodyText.length > 100;

    results.checks.push({
      name: 'Page content loads',
      status: (!hasErrorText && hasContent) ? 'PASS' : 'FAIL',
      details: `Content length: ${bodyText.length} chars, No error messages: ${!hasErrorText}`,
      expected: 'Content present, no error messages',
      actual: hasContent ? 'Content present' : 'No content'
    });
    console.log(`  Content length: ${bodyText.length} chars ${hasContent ? '✓' : '✗'}`);
    console.log(`  No error messages: ${!hasErrorText ? '✓' : '✗'}`);

    // Check for Hugo Resume theme elements
    const hasHeader = await page.locator('header').count() > 0;
    const hasResumeSections = await page.locator('section').count() > 0;
    console.log(`  Hugo theme elements: header=${hasHeader}, sections=${hasResumeSections} ${(hasHeader || hasResumeSections) ? '✓' : '✗'}`);

    // Check 3: Check network requests for asset errors
    console.log('\n✓ Check 3: Checking network requests for asset errors');
    const errorRequests = networkRequests.filter(req => req.status >= 400);
    const cssRequests = networkRequests.filter(req => req.url.includes('.css'));
    const jsRequests = networkRequests.filter(req => req.url.includes('.js'));
    const fontRequests = networkRequests.filter(req => req.url.match(/\.(woff2?|ttf|otf|eot)/));
    const imageRequests = networkRequests.filter(req => req.url.match(/\.(png|jpg|jpeg|gif|svg|webp)/));

    results.checks.push({
      name: 'No 404 errors for assets',
      status: errorRequests.length === 0 ? 'PASS' : 'FAIL',
      details: `Total requests: ${networkRequests.length}, Errors (>=400): ${errorRequests.length}`,
      expected: '0 error requests',
      actual: `${errorRequests.length} error requests`,
      errorRequests: errorRequests.map(r => ({ url: r.url, status: r.status }))
    });

    console.log(`  Total requests: ${networkRequests.length}`);
    console.log(`  CSS requests: ${cssRequests.length} (errors: ${cssRequests.filter(r => r.status >= 400).length})`);
    console.log(`  JS requests: ${jsRequests.length} (errors: ${jsRequests.filter(r => r.status >= 400).length})`);
    console.log(`  Font requests: ${fontRequests.length} (errors: ${fontRequests.filter(r => r.status >= 400).length})`);
    console.log(`  Image requests: ${imageRequests.length} (errors: ${imageRequests.filter(r => r.status >= 400).length})`);
    console.log(`  Total errors (>=400): ${errorRequests.length} ${errorRequests.length === 0 ? '✓' : '✗'}`);

    if (errorRequests.length > 0) {
      console.log('  Error requests:');
      errorRequests.forEach(req => {
        console.log(`    - ${req.status} ${req.url}`);
      });
    }

    // Check 4: Verify OG meta tags
    console.log('\n✓ Check 4: Verifying OG meta tags');
    const ogTags = await page.evaluate(() => {
      const tags = {};
      const metaTags = document.querySelectorAll('meta[property^="og:"]');
      metaTags.forEach(tag => {
        tags[tag.getAttribute('property')] = tag.getAttribute('content');
      });
      return tags;
    });

    const hasOgImage = !!ogTags['og:image'];
    const hasOgTitle = !!ogTags['og:title'];
    const hasOgDescription = !!ogTags['og:description'];
    const allOgTagsPresent = hasOgImage && hasOgTitle && hasOgDescription;

    results.checks.push({
      name: 'OG meta tags present',
      status: allOgTagsPresent ? 'PASS' : 'FAIL',
      details: `og:image: ${hasOgImage}, og:title: ${hasOgTitle}, og:description: ${hasOgDescription}`,
      expected: 'All required OG tags present',
      actual: `og:image=${hasOgImage}, og:title=${hasOgTitle}, og:description=${hasOgDescription}`,
      ogTags
    });

    console.log(`  og:image: ${hasOgImage ? '✓' : '✗'} ${ogTags['og:image'] || 'missing'}`);
    console.log(`  og:title: ${hasOgTitle ? '✓' : '✗'} ${ogTags['og:title'] || 'missing'}`);
    console.log(`  og:description: ${hasOgDescription ? '✓' : '✗'} ${ogTags['og:description'] || 'missing'}`);

    // Check 5: Test mobile responsive
    console.log('\n✓ Check 5: Testing mobile responsive layout (375x667)');
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);

    const mobileSnapshot = await page.content();
    const mobileBodyText = await page.textContent('body');
    const hasOverflow = await page.evaluate(() => {
      return document.body.scrollWidth > window.innerWidth;
    });

    results.checks.push({
      name: 'Mobile responsive at 375px',
      status: !hasOverflow ? 'PASS' : 'FAIL',
      details: `No horizontal overflow: ${!hasOverflow}, Content renders: ${mobileBodyText.length > 100}`,
      expected: 'Layout adapts without horizontal overflow',
      actual: hasOverflow ? 'Horizontal overflow detected' : 'Layout renders correctly'
    });

    console.log(`  Viewport: 375x667`);
    console.log(`  Horizontal overflow: ${hasOverflow ? '✗ YES' : '✓ NO'}`);
    console.log(`  Content renders: ${mobileBodyText.length > 100 ? '✓' : '✗'}`);

    // Take mobile screenshot
    await page.screenshot({
      path: '/Users/adial/Documents/GitHub/athan-dial.github.io/.planning/quick/2-run-phase-3-task-2-production-verificati/mobile-screenshot.png',
      fullPage: false
    });
    console.log('  Screenshot saved: mobile-screenshot.png');

    // Reset to desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForTimeout(500);

    // Check 6: Test dark mode toggle
    console.log('\n✓ Check 6: Testing dark mode toggle');
    const darkModeToggle = await page.locator('[data-bs-theme-toggle], [class*="theme-toggle"], button[aria-label*="theme" i]').first();
    const toggleExists = await darkModeToggle.count() > 0;

    if (toggleExists) {
      const initialTheme = await page.evaluate(() => {
        return document.documentElement.getAttribute('data-bs-theme') ||
               document.body.className;
      });

      await darkModeToggle.click();
      await page.waitForTimeout(500);

      const afterToggleTheme = await page.evaluate(() => {
        return document.documentElement.getAttribute('data-bs-theme') ||
               document.body.className;
      });

      const themeChanged = initialTheme !== afterToggleTheme;

      results.checks.push({
        name: 'Dark mode toggle functional',
        status: themeChanged ? 'PASS' : 'FAIL',
        details: `Toggle exists: ${toggleExists}, Theme changed: ${themeChanged}`,
        expected: 'Theme changes when toggle clicked',
        actual: `Initial: ${initialTheme}, After: ${afterToggleTheme}`
      });

      console.log(`  Toggle exists: ✓`);
      console.log(`  Initial theme: ${initialTheme}`);
      console.log(`  After toggle: ${afterToggleTheme}`);
      console.log(`  Theme changed: ${themeChanged ? '✓' : '✗'}`);
    } else {
      results.checks.push({
        name: 'Dark mode toggle functional',
        status: 'N/A',
        details: 'No dark mode toggle found on page',
        expected: 'Toggle present or confirmed not implemented',
        actual: 'Toggle not found'
      });
      console.log('  Dark mode toggle: Not found (may not be implemented)');
    }

    // Check 7: Check JavaScript console for errors
    console.log('\n✓ Check 7: Checking JavaScript console for errors');
    const errorMessages = consoleMessages.filter(msg => msg.type === 'error');
    const warningMessages = consoleMessages.filter(msg => msg.type === 'warning');

    results.checks.push({
      name: 'No JavaScript console errors',
      status: errorMessages.length === 0 ? 'PASS' : 'FAIL',
      details: `Errors: ${errorMessages.length}, Warnings: ${warningMessages.length}`,
      expected: '0 console errors',
      actual: `${errorMessages.length} errors, ${warningMessages.length} warnings`,
      errors: errorMessages.map(m => m.text),
      warnings: warningMessages.map(m => m.text)
    });

    console.log(`  Console errors: ${errorMessages.length} ${errorMessages.length === 0 ? '✓' : '✗'}`);
    console.log(`  Console warnings: ${warningMessages.length}`);

    if (errorMessages.length > 0) {
      console.log('  Error messages:');
      errorMessages.forEach(msg => {
        console.log(`    - ${msg.text}`);
      });
    }

    // Take final desktop screenshot
    console.log('\n✓ Taking desktop screenshot');
    await page.screenshot({
      path: '/Users/adial/Documents/GitHub/athan-dial.github.io/.planning/quick/2-run-phase-3-task-2-production-verificati/desktop-screenshot.png',
      fullPage: true
    });
    console.log('  Screenshot saved: desktop-screenshot.png');

  } catch (error) {
    console.error('\n✗ Error during verification:', error.message);
    results.error = error.message;
    results.checks.push({
      name: 'Verification execution',
      status: 'FAIL',
      details: error.message,
      expected: 'All checks complete',
      actual: 'Error during execution'
    });
  } finally {
    await browser.close();
  }

  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('VERIFICATION SUMMARY');
  console.log('='.repeat(60));

  const passed = results.checks.filter(c => c.status === 'PASS').length;
  const failed = results.checks.filter(c => c.status === 'FAIL').length;
  const na = results.checks.filter(c => c.status === 'N/A').length;
  const total = results.checks.length;

  results.summary = {
    total,
    passed,
    failed,
    na,
    allPassed: failed === 0
  };

  console.log(`Total checks: ${total}`);
  console.log(`Passed: ${passed} ✓`);
  console.log(`Failed: ${failed} ${failed > 0 ? '✗' : ''}`);
  console.log(`N/A: ${na}`);
  console.log(`Overall: ${results.summary.allPassed ? 'PASS ✓' : 'FAIL ✗'}`);

  console.log('\nDetailed Results:');
  results.checks.forEach((check, i) => {
    const icon = check.status === 'PASS' ? '✓' : check.status === 'FAIL' ? '✗' : '—';
    console.log(`${i + 1}. [${icon}] ${check.name}: ${check.status}`);
    console.log(`   ${check.details}`);
  });

  // Save results to JSON
  const fs = require('fs');
  fs.writeFileSync(
    '/Users/adial/Documents/GitHub/athan-dial.github.io/.planning/quick/2-run-phase-3-task-2-production-verificati/verification-results.json',
    JSON.stringify(results, null, 2)
  );
  console.log('\n✓ Results saved to: verification-results.json');

  return results;
}

verifyDeployment()
  .then(results => {
    process.exit(results.summary.allPassed ? 0 : 1);
  })
  .catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
