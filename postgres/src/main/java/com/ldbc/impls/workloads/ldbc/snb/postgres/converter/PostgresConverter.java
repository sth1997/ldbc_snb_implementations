package com.ldbc.impls.workloads.ldbc.snb.postgres.converter;

import com.ldbc.impls.workloads.ldbc.snb.converter.Converter;

import java.sql.Array;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.stream.Collectors;

public class PostgresConverter extends Converter {

    final static String DATETIME_FORMAT = "yyyyMMddHHmmssSSS";
    final static String DATE_FORMAT = "yyyyMMdd";

    @Override
    public String convertDateTime(Date date) {
        final SimpleDateFormat sdf = new SimpleDateFormat(DATETIME_FORMAT);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        return sdf.format(date);
    }

    @Override
    public String convertDate(Date date) {
        final SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        return sdf.format(date);
    }

    @Override
    public String convertString(String value) {
        return "'" + value.replace("'", "''") + "'";
    }

    public String convertStringList(List<String> values) {
        return "'{" +
                values
                        .stream()
                        .map(v -> "\"" + v + "\"")
                        .collect(Collectors.joining(", ")) +
                "}'::text[]";
    }


    public static Iterable<String> arrayToStringArray(ResultSet r, int column) throws SQLException {
        Array value = r.getArray(column);
        if (value == null) {
            return new ArrayList<>();
        } else {
            String[] strs = (String[]) value.getArray();
            List<String> array = new ArrayList<>();
            for (int i = 0; i < strs.length; i++) {
                array.add(strs[i]);
            }
            return array;
        }
    }

    public static Iterable<List<Object>> arrayToObjectArray(ResultSet r, int column) throws SQLException {
        Array value = r.getArray(column);
        if (value == null) {
            return new ArrayList<>();
        } else {
            Object[][] strs = (Object[][]) value.getArray();
            List<List<Object>> array = new ArrayList<>();
            for (int i = 0; i < strs.length; i++) {
                array.add(new ArrayList(Arrays.asList(strs[i])));
            }
            return array;
        }
    }

    public static Iterable<Long> convertLists(Iterable<List<Object>> arr) {
        List<Long> new_arr = new ArrayList<>();
        List<List<Object>> better_arr = (List<List<Object>>) arr;
        for (List<Object> entry : better_arr) {
            new_arr.add((Long) entry.get(0));
        }
        new_arr.add((Long) better_arr.get(better_arr.size() - 1).get(1));
        return new_arr;
    }

    private static long convertDateTimesToEpoch(long dateValue, String format) throws ParseException {
        final SimpleDateFormat sdf = new SimpleDateFormat(format);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        return sdf.parse(Long.toString(dateValue)).toInstant().toEpochMilli();

    }

    /**
     * Converts timestamp strings (in the format produced by DATAGEN) ({@value #DATAGEN_FORMAT})
     * to a date.
     *
     * @param timestamp
     * @return
     */
    public static long convertLongTimestampToEpoch(long timestamp) throws ParseException {
        return convertDateTimesToEpoch(timestamp, DATETIME_FORMAT);
    }

    /**
     * Converts timestamp strings (in the format produced by DATAGEN) ({@value #DATE_FORMAT})
     * to a date.
     *
     * @param date
     * @return
     */
    public static long convertLongDateToEpoch(long date) throws ParseException {
        return convertDateTimesToEpoch(date, DATE_FORMAT);
    }

    public static int convertStartAndEndDateToLatency(long from, long to) throws ParseException {
        long fromEpoch = convertDateTimesToEpoch(from, DATETIME_FORMAT);
        long toEpoch = convertDateTimesToEpoch(to, DATETIME_FORMAT);
        return (int)((toEpoch - fromEpoch) / 1000 / 60);
    }

    public static long stringTimestampToEpoch(ResultSet r, int column) throws SQLException {
        final long dateAsLong = r.getLong(column);
        try {
            return convertLongDateToEpoch(dateAsLong);
        } catch (ParseException e) {
            throw new SQLException(e);
        }
    }

}
