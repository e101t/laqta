function validateEnrollmentEligibility(courseData) {
  if (!courseData) return "course_not_found";
  if (courseData.isPublished !== true) return "course_not_published";
  if (
    typeof courseData.seatsRemaining !== "number" ||
    courseData.seatsRemaining <= 0
  ) {
    return "course_full";
  }
  return null;
}

module.exports = {
  validateEnrollmentEligibility,
};
