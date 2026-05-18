const ISO_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

const toStartOfLocalDay = (dateStr: string) => {
  const [year, month, day] = dateStr.split('-').map(Number);
  if (year === undefined || month === undefined || day === undefined) {
    throw new Error(`Invalid date string: ${dateStr}`);
  }
  return new Date(year, month - 1, day, 0, 0, 0, 0);
};

const parseDate = (d: Date | string): Date => {
  const date =
    typeof d === 'string'
      ? ISO_DATE_REGEX.test(d)
        ? toStartOfLocalDay(d)
        : new Date(d)
      : d;

  if (isNaN(date.getTime())) {
    throw new Error('Invalid date');
  }
  return date;
};

const mdyf = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
});

const asMonthDayYear = (input?: Date | string) => {
  if (!input) {
    return '';
  }
  const date = parseDate(input);
  return mdyf.format(date);
};

export { asMonthDayYear };
