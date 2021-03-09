import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class SIS {
    private static String fileSep = File.separator;
    private static String lineSep = System.lineSeparator();
    private static String space   = " ";

    private List<Student> studentList = new ArrayList<>();

    public SIS(){ processOptics(); }

    private void processOptics(){
        // TODO
        // read files
        try {
            // read the files that ends with .txt
            Files.newDirectoryStream(Paths.get("./input"), path -> path.toString().endsWith(".txt"))
                    .forEach(temp -> {
                        // for each file perform reading...
                        try(Stream<String> stream = Files.lines(Paths.get(temp.toAbsolutePath().toString()))){
                            List<String> list = new ArrayList<>();
                            list = stream.collect(Collectors.toList());

                            // obtain each line for a optical form.
                            String firstLine = list.get(0);
                            String secondLine = list.get(1);
                            String thirdLine = list.get(2);
                            String fourthLine = list.get(3);

                            // extract every field from each line.
                            String name = firstLine.substring(0,firstLine.substring(0,firstLine.lastIndexOf(space))
                                    .lastIndexOf(space));
                            String surname = firstLine.substring(0, firstLine.lastIndexOf(space)).
                                    substring(firstLine.substring(0, firstLine.lastIndexOf(space)).lastIndexOf(space)+1);
                            int studentID = Integer.parseInt( firstLine.substring(firstLine.lastIndexOf(space)+1));

                            int year = Integer.parseInt(secondLine.substring(0,secondLine.indexOf(space)));
                            int courseCode = Integer.parseInt( secondLine.substring(secondLine.indexOf(space) + 1,
                                    secondLine.lastIndexOf(space)));
                            int courseCredit = Integer.parseInt(secondLine.substring(secondLine.lastIndexOf(space)+ 1));
                            String examType = thirdLine;
                            String answers = fourthLine;

                            //From one optical form, create a student if it does not exist. if exists then
                            // update its information.
                            Student student = studentList.stream()
                                    .filter(s ->  studentID == s.getStudentID())
                                    .findAny()
                                    .orElse(null);

                            if(student == null){
                                // if student does not exist
                                String [] nameArray = Arrays.stream(name.split(space)).toArray(String[]::new);
                                student = new Student(nameArray,surname,studentID);
                                studentList.add(student);
                            }
                            // Add the course to the TakenCourses of the student.
                            // Firstly, calculate the grade
                            long countOfT =  answers.chars()
                                    .filter(c -> c == 'T' )
                                    .count();
                            long countOfTotalQuestions = answers.chars()
                                    .count();
                            // 100 points is assumed to be the highest score.
                            double grade =  countOfT*(100.0/countOfTotalQuestions);
                            Course course = new Course(courseCode, year, examType, courseCredit, grade);
                            // a new course can be added to takenCourses since it is a list and mutable object.
                            student.getTakenCourses().add(course);

                        } catch (IOException e){
                         // print the stack trace in case of exception.
                            e.printStackTrace();
                        }
                    });
        }catch (IOException e){
            // print the stack trace in case of exception.
            e.printStackTrace();
        }
    }

    public double getGrade(int studentID, int courseCode, int year){
        // TODO
        Student student = studentList.stream() //create stream on student list
                .filter(s -> s.getStudentID() == studentID) // filter by studentID
                .findFirst() // get the first match
                .orElse(null);// if there is no such student then return null

        if(student == null){
            // if student is null there is no such student
            System.out.println("Student with provided studentID" + studentID + " does not exist!");
        }
        List<Course> coursesTaken = student.getTakenCourses();
        // collect all the course entries for given year in courses List.
        double mixedGrade = coursesTaken.stream() //create stream on courses taken by the student.
                .filter(s -> s.getCourseCode() == courseCode && s.getYear() == year) // filter by desired course code and year
                .mapToDouble( s -> { // since there will be three exams' info provided for each course taken
                    double grade = s.getGrade(); //map those exams to their grades but first multiply with correct weight coefficient
                    if(s.getExamType().equals( "Midterm1")){
                        return 0.25*grade;
                    }else if(s.getExamType().equals( "Midterm2")){
                        return 0.25*grade;
                    }else if(s.getExamType().equals( "Final")){
                        return 0.5*grade;
                    }else{
                        System.out.println("There is a mistake with courseType!");
                        return 0;
                    }
                }).sum(); //then sum all of the exam results to get the total grade

        if( coursesTaken.stream().filter(s ->s.getCourseCode() == courseCode && s.getYear() == year).count() != 3 ){
            // if there is more than 3 course that is taken each year with the same courseCode then there is a mistake
            // with the input that is provided.
            System.out.println("There is an mistake with the exam count for the course" +
                    " with courseID: " + courseCode + " in the year: " + year);
            System.out.println("course count " + coursesTaken.stream().filter(s -> s.getYear() == year).count());
            System.out.println("");
        }
        return mixedGrade;
    }

    public void updateExam(int studentID, int courseCode, String examType, double newGrade){
        // TODO
        // query the most recent year's course entries
        // then update the given exam type.
        Student student = studentList.stream()
                .filter(s -> s.getStudentID() == studentID)
                .findFirst()
                .orElse(null); // get the student if exist or return null.

        if(student == null){
            // there is no such student with provided studentID and taken course with courseCode and examType
            // therefore; there is no possibility of updating exam info.
            System.out.println("Student with provided studentID" + studentID + " does not exist!");
        }
         Course mostRecentTakenCourse = student.getTakenCourses().stream() // create stream taken courses by the student
                .filter(course ->  course.getExamType().equals(examType) && course.getCourseCode() == courseCode)
                .max(Comparator.comparing(Course::getYear))// filter by examType and courseCode
                .get();// get the most recent course with provided info...
        mostRecentTakenCourse.setGrade(newGrade); // set the new grade as given
    }

    public void createTranscript(int studentID){
        // TODO
        // create stream on students to find the target student
        Student student = studentList.stream()
                .filter(s -> s.getStudentID() == studentID)
                .findAny()
                .orElse(null); //gets the student with the provided info if exists if not returns null

        if(student == null){
            // if student is null there is no such student with provided info. There is a problem with
            // the provided input.

            System.out.println("Student with provided studentID" + studentID + " does not exist!");
        }
        student.getTakenCourses().stream()// create stream on taken courses by the student
                .sorted( Comparator.comparing(Course::getYear).thenComparing(Course::getCourseCode))
                .mapToInt(course -> course.getYear())//sort by comparing by year and courseCode info. then mapToInt by year
                .distinct() //
                .filter(s -> {
                    System.out.println(s); // print the course year
                    student.getTakenCourses().stream() // create another stream over taken courses
                            .sorted( Comparator.comparing(Course::getYear).thenComparing(Course::getCourseCode))
                            .filter(c -> c.getYear() == s ) // compare and sort as above
                            .mapToInt(c -> c.getCourseCode()) // unlike above mapToInt by courseCode
                            .distinct()
                            .forEach(k -> {
                                // for each course get grade for provided courseCode and year
                                double grade = getGrade(studentID, k, s);
                                // by grade find letter grade
                                // below logic is taken from https://oidb.metu.edu.tr/en/course-credit-system
                                String letterGrade = "";
                                    if( grade >= 90 && grade <= 100){
                                        letterGrade = "AA";
                                    }else if(grade >= 85 && grade < 90){
                                        letterGrade = "BA";
                                    }else if(grade >= 80 && grade < 85){
                                        letterGrade = "BB";
                                    }else if(grade >= 75 && grade < 80){
                                        letterGrade = "CB";
                                    }else if(grade >= 70 && grade < 75){
                                        letterGrade = "CC";
                                    }else if(grade >= 65 && grade < 70){
                                        letterGrade = "DC";
                                    }else if(grade >= 60 && grade < 65){
                                        letterGrade = "DD";
                                    }else if(grade >= 50 && grade < 60){
                                        letterGrade = "FD";
                                    }else if(grade >= 0 && grade < 50){
                                        letterGrade = "FF";
                                    }else{
                                        System.out.println("There is a mistake with course grade");
                                    }
                                    System.out.println(k + space + letterGrade);
                            });
                    return true;
                }).count();

        // create a stream to get most recent taken courses so that CGPA will be calculated
        List<Course> mostRecentTakenCourses =
        student.getTakenCourses().stream()
                .collect(Collectors.groupingBy(Course::getCourseCode, //group courses taken by course codes.
                                        LinkedHashMap::new,
                                        Collectors.maxBy(Comparator.comparing(Course::getYear))))
                                        .values()// get the courses that are most recently taken
                                        .stream()
                                        .map(Optional::get)
                                        .collect(Collectors.toList()); // collect them in a list so that it will be reused.

        // calculate weights of most recent taken courses
        double weightOfMRTC = mostRecentTakenCourses.stream()
                .mapToDouble( i -> {
                    double grade = getGrade(studentID,i.getCourseCode(),i.getYear());
                    // map courses to their taken_grade * credit. by the logic that is
                    // provided at  https://oidb.metu.edu.tr/en/course-credit-system
                    double weight = 0;
                    if( grade >= 90 && grade <= 100){
                        weight = 4 * i.getCredit();
                    }else if(grade >= 85 && grade < 90){
                        weight = 3.5 * i.getCredit();
                    }else if(grade >= 80 && grade < 85){
                        weight = 3 * i.getCredit();
                    }else if(grade >= 75 && grade < 80){
                        weight = 2.5 * i.getCredit();
                    }else if(grade >= 70 && grade < 75){
                        weight = 2 * i.getCredit();
                    }else if(grade >= 65 && grade < 70){
                        weight = 1.5 * i.getCredit();
                    }else if(grade >= 60 && grade < 65){
                        weight = 1 * i.getCredit();
                    }else if(grade >= 50 && grade < 60){
                        weight = 0.5 * i.getCredit();
                    }else if(grade >= 0 && grade < 50){
                        weight = 0 * i.getCredit();
                    }else{
                        System.out.println("There is a mistake with course grade");
                    }
                    return weight;
                }).sum(); // sum all the most_recent_taken_grade * credit

        double totalAmountOfCreditsOfRTC = mostRecentTakenCourses.stream()
                .mapToDouble( i -> i.getCredit())
                .sum(); // find  most recent taken courses' credit total.

        // total weight / total credit
        double cGPA = weightOfMRTC / totalAmountOfCreditsOfRTC;
        System.out.println("CGPA: " + cGPA);
    }

    public void findCourse(int courseCode){
        // TODO
        studentList.stream()// create stream on students
                .flatMap( student -> student.getTakenCourses().stream()) // get all the courses given so far.
                .collect(Collectors.toList()) // collect them in a list
                .stream() // create another stream from the list
                .filter( c -> c.getCourseCode() == courseCode) // filter so that only the desired course is left.
                .mapToInt(c -> c.getYear() ) // map the course to the year that is was given
                .distinct()
                .sorted()
                .forEach(s -> {

                  long countOfStudentsTakenTheCourse =  studentList.stream() //create stream on students
                            .filter(student -> { // get all the students who took the course at the year
                                Course course =student.getTakenCourses().stream()// that was find in the other stream
                                        .filter(c -> c.getCourseCode() == courseCode && s == c.getYear())
                                        .findAny().orElse(null);

                                if(course == null){
                                    return false;
                                }else {
                                    return true;
                                }
                            }).count();//  find the total count of the students who fit provided constraints

                    System.out.println(s + space + countOfStudentsTakenTheCourse);
        });
    }

    public void createHistogram(int courseCode, int year){
        // TODO
       ArrayList<Double> grades = studentList.stream() // create a stream on students
                .filter(student -> { // filter students by course code and year that is provided.
                    Course c = student.getTakenCourses().stream()
                            .filter(course -> {
                               return course.getYear() == year && course.getCourseCode() == courseCode;
                            })
                            .findAny().orElse(null);
                    if(c == null){
                        // if this student did not take the course in given year
                        return false;
                    }else{
                     // student took the course in the given year
                     return true;
                    }
                }) // map filtered students to their grades then collect them in a Arraylist called grades to use later
              .map(s -> getGrade(s.getStudentID(), courseCode, year))
              .collect(Collectors.toCollection(ArrayList::new));

       // filter by the logic that is provided in the homework text and store results in
        // different variables to print them separately.
       long zero_ten = grades.stream().filter(s -> s >= 0 && s < 10).count();
       long ten_twenty = grades.stream().filter(s -> s >= 10 && s < 20).count();
       long twenty_thirty = grades.stream().filter(s -> s >= 20 && s < 30).count();
       long thirty_forty = grades.stream().filter(s -> s >= 30 && s < 40).count();
       long forty_fifty = grades.stream().filter(s -> s >= 40 && s < 50).count();
       long fifty_sixty = grades.stream().filter(s -> s >= 50 && s < 60).count();
       long sixty_seventy = grades.stream().filter(s -> s >= 60 && s < 70).count();
       long seventy_eighty = grades.stream().filter(s -> s >= 70 && s < 80).count();
       long eighty_ninety = grades.stream().filter(s -> s >= 80 && s < 90).count();
       long ninety_hundred = grades.stream().filter(s -> s >= 90 && s <100).count();

       //print results like it is stated in homework text.
        System.out.println("0-10" + space + zero_ten);
        System.out.println("10-20" + space + ten_twenty);
        System.out.println("20-30" + space + twenty_thirty);
        System.out.println("30-40" + space + thirty_forty);
        System.out.println("40-50" + space + forty_fifty);
        System.out.println("50-60" + space + fifty_sixty);
        System.out.println("60-70" + space + sixty_seventy);
        System.out.println("70-80" + space + seventy_eighty);
        System.out.println("80-90" + space + eighty_ninety);
        System.out.println("90-100" + space + ninety_hundred);
    }
}