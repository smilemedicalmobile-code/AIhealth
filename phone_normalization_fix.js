// Updated normalizePhone function to handle leading zero for Korean phone numbers
function normalizePhone(value) {
  if (!value) return "";

  // Convert to string and remove all non-numeric characters
  const cleaned = String(value).replace(/[^0-9]/g, '');

  if (cleaned === "") return "";

  // For Korean phone numbers: if starts with "10" (010, 011, etc.) but no leading 0, add it
  // This handles cases where Sheets strips the leading zero
  if (cleaned.startsWith("10") && cleaned.length >= 9) {
    return "0" + cleaned;
  }

  // Already has leading 0 or different format
  return cleaned;
}

// Test cases to verify
function testNormalizePhone() {
  console.log(normalizePhone("0104148399")); // Should output: 0104148399
  console.log(normalizePhone("104148399"));  // Should output: 0104148399
  console.log(normalizePhone("010-4148-399")); // Should output: 0104148399
  console.log(normalizePhone(104148399));    // Should output: 0104148399
  console.log(normalizePhone("02-1234-5678")); // Should output: 021234568 (Seoul landline)
}
