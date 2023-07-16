public class test {


public static void result() {
integer firstnumber, secondnumber, result;
firstnumber=1500;
secondnumber=1100;
result=firstnumber+secondnumber;
 system.debug('addition operation result is ....:'+result);
result=math.mod(firstnumber,secondnumber);
system.debug('reminder value is....:'+result);
}

}
/*
public with sharing class Sales_SalesPro {
  private static Map<String, String> fileIcons = new Map<String, String>{
    'PDF' => 'doctype:pdf',
    'CSV' => 'doctype:csv',
    'EXCEL' => 'doctype:excel',
    'EXCEL_M' => 'doctype:excel',
    'EXCEL_X' => 'doctype:excel',
    'JPG' => 'doctype:image',
    'JPEG' => 'doctype:image',
    'MOV' => 'doctype:video',
    'MP4' => 'doctype:video',
    'PNG' => 'doctype:image',
    'TIFF' => 'doctype:image',
    'POWER_POINT' => 'doctype:ppt',
    'POWER_POINT_X' => 'doctype:ppt',
    'WORD' => 'doctype:word',
    'WORD_X' => 'doctype:word',
    'EMAIL' => 'doctype:stypi',
    'LINK' => 'doctype:link',
    'UNKNOWN' => 'doctype:unknown'
  };

  public Sales_SalesPro() {
  }

  public class collateral {
    @AuraEnabled
    public String documentId { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String createdDate { get; set; }
    @AuraEnabled
    public String previewUrl { get; set; }
    @AuraEnabled
    public String downloadUrl { get; set; }
    @AuraEnabled
    public String fileType { get; set; }
    @AuraEnabled
    public String fileTypeIcon { get; set; }
    public collateral(contentDocument cd) {
      this.documentId = cd.id;
      this.title = cd.title;
      this.description = cd.description;
      this.createdDate = cd.createdDate.format('MM/dd/yyyy');
      this.previewUrl =
        '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' +
        cd.LatestPublishedVersionId;
      this.fileType = cd.fileType;
      this.fileTypeIcon = fileIcons.get(cd.FileType);
      this.downloadUrl =
        '/sfc/servlet.shepherd/version/download/' + cd.LatestPublishedVersionId;
    }
  }

  public class salespro {
    @AuraEnabled
    public String salesProId { get; set; }
    @AuraEnabled
    public String createdByName { get; set; }
    @AuraEnabled
    public String startDate { get; set; }
    @AuraEnabled
    public String hotelName { get; set; }
    @AuraEnabled
    public String restaurantName { get; set; }
    @AuraEnabled
    public Integer numberOfAttendees { get; set; }

    public salespro(Sales_Pro_2__c sp) {
      this.salesProId = sp.Id;
      this.createdByName = sp.createdBy.Name;
      this.startDate = '';
      if (sp.Training_Date__c != null)
        startDate = sp.Training_Date__c.format();
      this.hotelName = sp.Hotel_Name__c;
      this.restaurantName = sp.Day_1_Dinner_Restaurant_Name__c;
      Set<Id> uniqueAttendees = new Set<id>();
      for (Assigned_Assignment__c aa : sp.Assigned_Assignments__r) {
        uniqueAttendees.add(aa.User__c);
      }
      this.numberOfAttendees = uniqueAttendees.size();
    }
  }

  @AuraEnabled
  public static List<salespro> getSalesPros(String region, String classFilter) {
    String currentUserId = UserInfo.getUserId();
    String query =
      'SELECT Id, Name, Training_Date__c, Day_1_Start_Time__c, Hotel_Name__c, Day_1_Dinner_Restaurant_Name__c, ' +
      ' CreatedBy.Name, (select User__c from Assigned_Assignments__r) FROM Sales_Pro_2__c WHERE ';

    if (region == null || classFilter == 'mine') {
      query += ' OwnerId =: currentUserId';
    } else if (classFilter == 'team') {
      Set<Id> allSubRoleIds = getSubRoleIds(
        new Set<ID>{ UserInfo.getUserRoleId() }
      );
      allSubRoleIds.add(UserInfo.getUserRoleId());
      query += ' Id in (select Sales_Pro_2__c from Assigned_Assignment__c where User__r.UserRoleId in :allSubRoleIds)';
    } else {
      query += ' OwnerId in (select Id from user where region__c=:region)';
    }
    query += ' order by Training_Date__c desc';
    List<salespro> data = new List<salespro>();
    for (Sales_Pro_2__c sp : database.query(query)) {
      data.add(new salespro(sp));
    }
    // return Database.query(query);
    return data;
  }

  private static Set<Id> getSubRoleIds(Set<Id> roleIds) {
    Set<Id> returnRoleIds = new Set<Id>();
    for (UserRole r : [
      SELECT Id
      FROM UserRole
      WHERE ParentRoleId IN :roleIds AND ParentRoleID != NULL
    ]) {
      returnRoleIds.add(r.Id);
    }
    if (!returnRoleIds.isEmpty())
      returnRoleIds.addAll(getSubRoleIds(returnRoleIds));
    return returnRoleIds;
  }

  @AuraEnabled
  public static List<collateral> fetchFiles() {
    List<collateral> collaterals = new List<Collateral>();
    // String query =
    //   'SELECT Id, ContentDocumentId, Title, Description, CreatedDate, FileType ' +
    //   'FROM ContentVersion ' +
    //   'WHERE IsLatest = TRUE AND ((MOD_First_Name__c = \'' +
    //   UserInfo.getFirstName() +
    //   '\' ' +
    //   'AND MOD_Last_Name__c = \'' +
    //   UserInfo.getLastName() +
    //   '\') ' +
    //   'OR MOD_Email__c = \'' +
    //   UserInfo.getUserEmail() +
    //   '\')';

    List<ContentWorkspace> cw = [
      SELECT id
      FROM contentWorkspace
      WHERE name = 'SalesPro Plus'
    ];
    string salesProLibrary = '';
    if (!cw.isempty())
      salesProLibrary = cw[0].id;
    String query =
      'select LatestPublishedVersionId, id, title, description, createdDate, fileType ' +
      'from ContentDocument where ParentId=:salesProLibrary';

    // if (fileId != null && fileId != '')
    //   query += ' AND Id = \'' + fileId + '\'';
    return myCollaterals(Database.query(query));
  }

  private static List<collateral> myCollaterals(List<contentDocument> files) {
    List<collateral> collaterals = new List<Collateral>();
    for (contentDocument file : files) {
      collateral c = new collateral(file);
      collaterals.add(c);
    }
    return collaterals;
  }

  @AuraEnabled
  public static Map<String, List<String>> getUserFilter(String filter) {
    try {
      return Sales_AuraComponentHelper.getUserFilter(filter);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class aggregateQuestion extends Sales_AssignedAssignments.Question_Abstract {
    // @AuraEnabled
    // public List<Double> percentSelectedAnswerList { get; set; }
    // @AuraEnabled
    // public List<Integer> numberSelectedAnswerList { get; set; }
    @AuraEnabled
    public List<String> answersList { get; set; }

    @AuraEnabled
    public List<answerWrapper> answers { get; set; }
    @AuraEnabled
    public Integer totalSelected { get; set; }
    @AuraEnabled
    public Integer totalCorrect { get; set; }
    public aggregateQuestion() {
      // this.percentSelectedAnswerList = new List<Double>();
      // this.numberSelectedAnswerList = new List<Integer>();
      this.answersList = new List<String>();
      this.answers = new List<answerWrapper>();
      this.totalSelected = 0;
      this.totalCorrect = 0;
    }

    public aggregateQuestion(Sales_AssignedAssignments.Question q) {
      // this.percentSelectedAnswerList = new List<Double>();
      // this.numberSelectedAnswerList = new List<Integer>();
      this.answersList = new List<String>();
      this.answers = new List<answerWrapper>();
      this.totalSelected = 0;
      this.totalCorrect = 0;
      this.question = q.question;

      for (OptionWrapper answer : q.answers) {
        answersList.add(answer.label);
        answerWrapper aw = new answerWrapper(answer.label);
        if (q.answer == answer.label)
          aw.correct = true;
        answers.add(aw);
      }

      // if(!this.numberSelectedAnswerList.isEmpty() && !q.selectedAnswerList.isEmpty()){
      //   for(Sales_AssignedAssignments.Question q : q.selectedAnswerList) this.numberSelectedAnswerList.add(0);
      //   Integer index = q.selectedAnswerList.get(q.selectedAnswer);
      //   this.numberSelectedAnswerList[index]++;
      // }
    }
  }

  public class answerWrapper {
    // @AuraEnabled
    // public Double percentSelectedAnswer { get; set; }
    @AuraEnabled
    public Boolean correct { get; set; }
    @AuraEnabled
    public Integer numberSelectedAnswer { get; set; }
    @AuraEnabled
    public String answer { get; set; }

    public answerWrapper() {
      // this.percentSelectedAnswer = 0.00;
      this.correct = false;
      this.numberSelectedAnswer = 0;
      this.answer = '';
    }

    public answerWrapper(String answer) {
      // this.percentSelectedAnswer = 0.00;
      this.numberSelectedAnswer = 0;
      this.answer = answer;
      this.correct = false;
    }
  }

  public class Quiz extends Sales_AssignedAssignments.Quiz_Abstract {
    @AuraEnabled
    public Double averagePercentage { get; set; }
    @AuraEnabled
    public Double averageNumberCorrect { get; set; }
    @AuraEnabled
    public List<aggregateQuestion> aggregateQuestions { get; set; }

    public Quiz() {
      this.averagePercentage = 0.00;
      this.averageNumberCorrect = 0.00;

      this.hasSubmitted = false;
      this.canViewQuiz = false;
      this.isTimed = false;
      this.numberQuestions = 0;
      this.numberCorrect = 0;
      this.questions = new List<Sales_AssignedAssignments.Question>();
      this.aggregateQuestions = new List<aggregateQuestion>();
      this.name = 'Your';
    }

    public Quiz(Assignment__c a) {
      this.averagePercentage = 0.00;
      this.averageNumberCorrect = 0.00;

      this.numberQuestions = 0;
      this.numberCorrect = 0;
      this.title = a.Title__c;
      this.subtitle = a.Subtitle__c;
      this.description = a.Description__c;
      this.hasSubmitted = false;
      this.canViewQuiz = false;
      this.isTimed = a.Is_Timed__c;
      this.timeLimit = Integer.valueOf(a.Time_Limit_Seconds__c);
      this.questions = new List<Sales_AssignedAssignments.Question>();
      this.aggregateQuestions = new List<aggregateQuestion>();
      this.name = 'Your';
    }
  }

  @AuraEnabled
  public static Quiz getAggregateQuiz(
    String region,
    String classFilter,
    String sppId
  ) {
    String currentUserId = UserInfo.getUserId();
    String query = '';
    if (sppId != null) {
      query = ' select JSON__c from Assigned_Assignment__c where Sales_Pro_2__c = :sppId and Assignment__r.type__c=\'Quiz\'';
    } else if (region == null || classFilter == 'mine') {
      query = ' select JSON__c from Assigned_Assignment__c where Sales_Pro_2__r.OwnerId =: currentUserId and Assignment__r.type__c=\'Quiz\'';
    } else if (classFilter == 'team') {
      Set<Id> allSubRoleIds = getSubRoleIds(
        new Set<ID>{ UserInfo.getUserRoleId() }
      );
      allSubRoleIds.add(UserInfo.getUserRoleId());
      query = ' select JSON__c from Assigned_Assignment__c where User__r.UserRoleId in :allSubRoleIds and Assignment__r.type__c=\'Quiz\'';
    } else {
      List<Sales_Pro_2__c> spIds = [
        SELECT id
        FROM Sales_Pro_2__c
        WHERE OwnerId IN (SELECT id FROM user WHERE region__c = :region)
      ];
      query = ' select JSON__c from Assigned_Assignment__c where Sales_Pro_2__c in :spIds and Assignment__r.type__c=\'Quiz\'';
    }

    Quiz aggregateQuiz = new Quiz();

    Map<String, aggregateQuestion> ags = new Map<String, aggregateQuestion>();
    Integer correct = 0, numberOfQuizes = 0, numberOfQuestions = 0;
    for (Assigned_Assignment__c assignment : database.query(query)) {
      if (assignment.JSON__c != null) {
        numberOfQuizes++;
        //   this.correct = false;
        // this.answer = q.Correct_Answer__c;
        // this.selectedAnswer = null;
        // this.selectedAnswerList = new List<String>();
        // this.question = q.Question__c;
        // this.answers = new List<OptionWrapper>();
        // if (q.Answers__c != null) {
        //   for (String s : q.Answers__c.split('\\r\n'))
        //     this.answers.add(new OptionWrapper(s));
        // }
        // this.questionNumber = Integer.valueOf(q.Question_Number__c);
        // this.questionType = q.type__c;
        // this.isGraded = q.Is_Graded__c;

        Quiz tempQuiz = (Quiz) JSON.deserialize(assignment.JSON__c, Quiz.class);
        // numberOfQuestions = tempQuiz.questions.size() + numberOfQuestions;
        for (Sales_AssignedAssignments.Question q : tempQuiz.questions) {
          if (!ags.containsKey(q.question)) {
            ags.put(q.question, new aggregateQuestion(q));
          }

          aggregateQuestion aq = ags.get(q.question);
          aq.totalSelected++;

          numberOfQuestions++;

          // Integer index = aq.answersList.indexOf(q.selectedAnswer);
          // if (index >= 0 && index < aq.answersList.size()) {
          //   aq.numberSelectedAnswerList[index]++;
          //   if (aq.totalSelected > 0)
          //     aq.percentSelectedAnswerList[index] = ((Decimal.valueOf(
          //         aq.numberSelectedAnswerList[index]
          //       ) / Decimal.valueOf(aq.totalSelected)) * 100)
          //       .setScale(2);
          // }

          Integer index = aq.answersList.indexOf(q.selectedAnswer);
          if (index >= 0 && index < aq.answers.size()) {
            aq.answers[index].numberSelectedAnswer++;
            // if (aq.totalSelected > 0)
            // aq.answers[index].percentSelectedAnswer = ((Decimal.valueOf(
            //     aq.answers[index].numberSelectedAnswer
            //   ) / Decimal.valueOf(aq.totalSelected)) * 100)
            //   .setScale(2);

            // aq.answers[index].percentSelectedAnswer = Decimal.valueOf(
            //   aq.answers[index].numberSelectedAnswer
            // ) / Decimal.valueOf(aq.totalSelected);
          }

          if (q.correct) {
            correct = correct + 1;
            aq.totalCorrect++;
          }
        }
      }
    }
    Decimal averageNumberOfQuestions = 0;
    if (numberOfQuizes > 0) {
      averageNumberOfQuestions = numberOfQuestions / numberOfQuizes;
    }
    if (numberOfQuestions > 0) {
      Decimal correctRatio = (Double.valueOf(correct) /
      Double.valueOf(numberOfQuestions));
      aggregateQuiz.averageNumberCorrect = (correctRatio *
        averageNumberOfQuestions)
        .setScale(2);
      aggregateQuiz.averagePercentage = (correctRatio * 100.00).setScale(2);
    }
    aggregateQuiz.aggregateQuestions = ags.values();
    return aggregateQuiz;

    // return new Quiz();
  }

  public class sixBySix {
    @AuraEnabled
    public String userId { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    // @AuraEnabled
    // public List<Double> admits { get; set; }
    @AuraEnabled
    public Double admitTrainingDate { get; set; }
    @AuraEnabled
    public Double admitMinus5 { get; set; }
    @AuraEnabled
    public Double admitMinus4 { get; set; }
    @AuraEnabled
    public Double admitMinus3 { get; set; }
    @AuraEnabled
    public Double admitMinus2 { get; set; }
    @AuraEnabled
    public Double admitMinus1 { get; set; }
    @AuraEnabled
    public Double admitPlus6 { get; set; }
    @AuraEnabled
    public Double admitPlus5 { get; set; }
    @AuraEnabled
    public Double admitPlus4 { get; set; }
    @AuraEnabled
    public Double admitPlus3 { get; set; }
    @AuraEnabled
    public Double admitPlus2 { get; set; }
    @AuraEnabled
    public Double admitPlus1 { get; set; }
    public sixBySix() {
      this.userId = '';
      this.name = '';
      this.startDate = null;
      // this.admits = new List<Double>();
      // for (Integer i = 0; i < 12; i++) {
      //   this.admits.add(0.0);
      // }
      this.admitMinus5 = 0.0;
      this.admitMinus4 = 0.0;
      this.admitMinus3 = 0.0;
      this.admitMinus2 = 0.0;
      this.admitMinus1 = 0.0;
      this.admitTrainingDate = 0.0;
      this.admitPlus6 = 0.0;
      this.admitPlus5 = 0.0;
      this.admitPlus4 = 0.0;
      this.admitPlus3 = 0.0;
      this.admitPlus2 = 0.0;
      this.admitPlus1 = 0.0;
    }
    public sixBySix(Assigned_Assignment__c aa) {
      this.userId = aa.User__c;
      this.name = aa.User__r.name;
      this.startDate = aa.Training_Date__c;
      // this.admits = new List<Double>();
      // for (Integer i = 0; i < 12; i++) {
      //   this.admits.add(0.0);
      // }
      this.admitTrainingDate = 0.0;
      this.admitMinus5 = 0.0;
      this.admitMinus4 = 0.0;
      this.admitMinus3 = 0.0;
      this.admitMinus2 = 0.0;
      this.admitMinus1 = 0.0;
      this.admitPlus6 = 0.0;
      this.admitPlus5 = 0.0;
      this.admitPlus4 = 0.0;
      this.admitPlus3 = 0.0;
      this.admitPlus2 = 0.0;
      this.admitPlus1 = 0.0;
    }
  }

  @AuraEnabled
  public static List<sixBySix> getSixBySix(
    String region,
    String classFilter,
    String sppId
  ) {
    try {
      Map<Id, Map<Date, sixBySix>> data = new Map<Id, Map<Date, sixBySix>>();

      String currentUserId = UserInfo.getUserId();
      String query = '';
      if (sppId != null) {
        query = ' select User__c, User__r.name, Training_Date__c from Assigned_Assignment__c where Training_Date__c!=null and Sales_Pro_2__c = :sppId order by Training_Date__c';
      } else if (region == null || classFilter == 'mine') {
        query = ' select User__c, User__r.name, Training_Date__c from Assigned_Assignment__c where Training_Date__c!=null and Sales_Pro_2__r.OwnerId =: currentUserId order by Training_Date__c';
      } else if (classFilter == 'team') {
        Set<Id> allSubRoleIds = getSubRoleIds(
          new Set<ID>{ UserInfo.getUserRoleId() }
        );
        allSubRoleIds.add(UserInfo.getUserRoleId());
        query = ' select User__c, User__r.name, Training_Date__c from Assigned_Assignment__c where Training_Date__c!=null and User__r.UserRoleId in :allSubRoleIds order by Training_Date__c';
      } else {
        List<Sales_Pro_2__c> spIds = [
          SELECT id
          FROM Sales_Pro_2__c
          WHERE OwnerId IN (SELECT id FROM user WHERE region__c = :region)
        ];
        query = ' select User__c, User__r.name, Training_Date__c from Assigned_Assignment__c where Training_Date__c!=null and Sales_Pro_2__c in :spIds order by Training_Date__c';
      }

      Date lowDate, highDate;
      // Map<Id, sixBySix> returnData = new Map<Id, sixBySix>();

      List<Assigned_Assignment__c> assignments = database.query(query);
      Set<Id> userIds = new Set<Id>();
      for (Assigned_Assignment__c assignment : assignments) {
        Id userId = assignment.User__c;
        userIds.add(userId);
        if (assignment.Training_Date__c != null) {
          if (lowDate == null)
            lowDate = assignment.Training_Date__c;
          if (assignment.Training_Date__c < lowDate)
            lowDate = assignment.Training_Date__c;
          if (highDate == null)
            highDate = assignment.Training_Date__c;
          if (assignment.Training_Date__c > highDate)
            highDate = assignment.Training_Date__c;
        }

        if (data.containsKey(userId)) {
          data.get(userId)
            .put(assignment.Training_Date__c, new sixBySix(assignment));
        } else {
          Map<Date, sixBySix> temp = new Map<Date, sixBySix>();
          temp.put(assignment.Training_Date__c, new sixBySix(assignment));
          data.put(userId, temp);
        }
      }

      Map<Id, Map<Date, Decimal>> spData = new Map<Id, Map<Date, Decimal>>();
      if (lowDate != null & highDate != null) {
        lowDate = lowDate.toStartOfMonth().addMonths(-5);
        highDate = highDate.toStartOfMonth().addMonths(6);
        for (Sales_Performance__c sp : [
          SELECT OwnerId, KAH_Growth_Admit_Actual__c, month__c
          FROM Sales_Performance__c
          WHERE
            ownerId IN :userIds
            AND KAH_Growth_Admit_Actual__c != NULL
            AND month__c >= :lowDate
            AND month__c <= :highDate
        ]) {
          if (spData.containsKey(sp.OwnerId)) {
            spData.get(sp.OwnerId)
              .put(sp.month__c, sp.KAH_Growth_Admit_Actual__c);
          } else {
            Map<Date, Decimal> temp = new Map<Date, Decimal>();
            temp.put(sp.month__c, sp.KAH_Growth_Admit_Actual__c);
            spData.put(sp.OwnerId, temp);
          }
        }
      }

      for (Assigned_Assignment__c assignment : assignments) {
        Date trainingDate = assignment.Training_Date__c;
        Date startDate = trainingDate.toStartOfMonth();
        Id userId = assignment.user__c;

        if (spData.containsKey(userId)) {
          Map<Date, Decimal> temp = spData.get(userId);
          if (temp.containsKey(startDate))
            data.get(userId).get(trainingDate).admitTrainingDate = temp.get(
              startDate
            );
          if (temp.containsKey(startDate.addMonths(-1)))
            data.get(userId).get(trainingDate).admitMinus1 = temp.get(
              startDate.addMonths(-1)
            );
          if (temp.containsKey(startDate.addMonths(-2)))
            data.get(userId).get(trainingDate).admitMinus2 = temp.get(
              startDate.addMonths(-2)
            );
          if (temp.containsKey(startDate.addMonths(-3)))
            data.get(userId).get(trainingDate).admitMinus3 = temp.get(
              startDate.addMonths(-3)
            );
          if (temp.containsKey(startDate.addMonths(-4)))
            data.get(userId).get(trainingDate).admitMinus4 = temp.get(
              startDate.addMonths(-4)
            );
          if (temp.containsKey(startDate.addMonths(-5)))
            data.get(userId).get(trainingDate).admitMinus5 = temp.get(
              startDate.addMonths(-5)
            );
          if (temp.containsKey(startDate.addMonths(1)))
            data.get(userId).get(trainingDate).admitPlus1 = temp.get(
              startDate.addMonths(1)
            );
          if (temp.containsKey(startDate.addMonths(2)))
            data.get(userId).get(trainingDate).admitPlus2 = temp.get(
              startDate.addMonths(2)
            );
          if (temp.containsKey(startDate.addMonths(3)))
            data.get(userId).get(trainingDate).admitPlus3 = temp.get(
              startDate.addMonths(3)
            );
          if (temp.containsKey(startDate.addMonths(4)))
            data.get(userId).get(trainingDate).admitPlus4 = temp.get(
              startDate.addMonths(4)
            );
          if (temp.containsKey(startDate.addMonths(5)))
            data.get(userId).get(trainingDate).admitPlus5 = temp.get(
              startDate.addMonths(5)
            );
          if (temp.containsKey(startDate.addMonths(6)))
            data.get(userId).get(trainingDate).admitPlus6 = temp.get(
              startDate.addMonths(6)
            );
        }
      }
      List<sixBySix> returnData = new List<sixBySix>();
      for (Map<Date, sixBySix> temp : data.values()) {
        returnData.addAll(temp.values());
      }
      return returnData;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}



@isTest(SeeAllData=false)
public class Sales_SalesProTest {
  @TestSetup
  static void makeData() {
    final ID SALES_KAH_Associate = AA_UtilityClass.getKAHAssociateID;
    User thisUser = [
      SELECT Id, UserRoleId, FirstName
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    System.runAs(thisUser) {
      AA_AssociateDataManagementController objDataManagement = new AA_AssociateDataManagementController();
      String PARENT_ROLE = 'SVP - KAH';
      UserRole objUserRole = [
        SELECT id
        FROM UserRole
        WHERE Name = :PARENT_ROLE
        LIMIT 1
      ];
      UserRole objUserRole1 = [
        SELECT id
        FROM UserRole
        WHERE ParentRoleId = :objUserRole.Id
        LIMIT 1
      ];
      UserRole objUserRole2 = [
        SELECT id
        FROM UserRole
        WHERE Name = :'SA - Test'
        LIMIT 1
      ];

      User objUser = new User(
        FirstName = 'testFirst',
        LastName = 'TestUser' + String.valueOf(Date.today()),
        Email = 'TestUser' +
          String.valueOf(Date.today()) +
          '_' +
          '@kindredathome.com',
        Username = 'TestUser_Test' +
          String.valueOf(Date.today()) +
          '_' +
          '@kindredathome.com',
        isActive = true,
        Alias = 'tu',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        ProfileId = SALES_KAH_Associate,
        CommunityNickname = 'TestCommunity1' +
          String.valueOf(Date.today()) +
          '_',
        Title = 'Home Health Specialist',
        City = 'testCity',
        Country = 'testCountry',
        Street = 'testStreet',
        CompanyName = 'testCompanyName',
        Phone = 'testPhone',
        Extension = 'testExtension',
        PostalCode = '2345',
        UserRoleid = objUserRole.id,
        Region__c = 'Test',
        Line_of_Business__c = 'HH',
        Area__c = 'Test',
        Market__c = 'Test'
      );
      insert objUser;

      User objUser2 = new User(
        FirstName = 'testSecond',
        LastName = 'TestUser',
        username = 'newUserDataManagement' +
          String.valueOf(Date.today()) +
          '_' +
          '@kindredathome.com',
        email = 'pb@kindredathome.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias = 'nuser',
        ProfileId = SALES_KAH_Associate,
        managerId = objUser.id,
        Perner__c = '546437576',
        Line_of_Business__c = 'HH',
        Region__c = 'Test',
        Area__c = 'Test',
        Title = 'Home Health Specialist',
        Market__c = 'Test',
        Date_of_Hire__c = Date.newInstance(
          System.now().year(),
          System.now().month() - 1,
          1
        )
      );
      insert objUser2;
      Sales_Performance__c sp = new Sales_Performance__c(
        KAH_HH_Adjusted_Admits__c = 12.0,
        KAH_HH_Admit_Target__c = 5.0,
        OwnerId = objUser2.Id,
        KAH_Adjusted__c = true,
        Month__c = Date.newInstance(
          System.now().year(),
          System.now().month(),
          1
        )
      );
      List<Sales_Performance__c> sps = new List<Sales_Performance__c>();
      sps.add(sp);
      sp = new Sales_Performance__c(
        KAH_HH_Adjusted_Admits__c = 12.0,
        KAH_HH_Admit_Target__c = 12.0,
        KAH_Adjusted__c = true,
        Admission_Details_JSON__c = '{"test":{}}',
        OwnerId = objUser.Id,
        Month__c = Date.newInstance(
          System.now().year(),
          System.now().month(),
          1
        )
      );
      sps.add(sp);
      insert sps;

      Account acct1 = new Account(Name = 'Test Account1');
      insert acct1;
      AccountTeamMember atm = new AccountTeamMember(
        UserId = objUser.Id,
        AccountId = acct1.Id
      );
      insert atm;

      Contact con = new Contact(
        LastName = 'Test Contact1',
        KAH_Account_Classification__c = 'A+'
      );
      insert con;
      Contact_Team__c ct = new Contact_Team__c(
        User__c = objUser.Id,
        Contact__c = con.Id
      );
      insert ct;

      Account acct2 = new Account(
        Name = 'Test Account2',
        KAH_Account_Classification__c = 'A+'
      );
      insert acct2;
      atm = new AccountTeamMember(UserId = objUser2.Id, AccountId = acct2.Id);
      insert atm;

      con = new Contact(LastName = 'Test Contact2');
      insert con;
      ct = new Contact_Team__c(User__c = objUser2.Id, Contact__c = con.Id);
      insert ct;

      List<Sales_account_metrics__c> ams = new List<Sales_account_metrics__c>();
      ams.add(
        new Sales_account_metrics__c(
          Name = '1',
          Account__c = acct1.Id,
          Month__c = Date.newInstance(System.now().year(), 1, 1),
          KAH_HH_PPS_Admits__c = 1
        )
      );
      ams.add(
        new Sales_account_metrics__c(
          Name = '2',
          Account__c = acct1.Id,
          Month__c = Date.newInstance(System.now().year(), 1, 1),
          KAH_HH_PPS_Admits__c = 1
        )
      );
      ams.add(
        new Sales_account_metrics__c(
          Name = '3',
          Account__c = acct1.Id,
          Month__c = Date.newInstance(System.now().year(), 6, 15),
          KAH_HH_Admits__c = 1,
          KAH_HP_Admits__c = 1,
          KAH_HH_Referrals__c = 1,
          KAH_HP_Referrals__c = 1,
          KAH_HH_PPS_Admits__c = 1
        )
      );
      ams.add(
        new Sales_account_metrics__c(
          Name = '4',
          Account__c = acct1.Id,
          Month__c = Date.newInstance(System.now().year(), 12, 31),
          KAH_HH_PPS_Admits__c = 1
        )
      );
      insert ams;

      List<Sales_contact_metrics__c> cms = new List<Sales_contact_metrics__c>();
      cms.add(
        new Sales_contact_metrics__c(
          Name = '1',
          Contact__c = con.Id,
          Month__c = date.newInstance(System.now().year(), 1, 1),
          KAH_HH_PPS_Admits__c = 1
        )
      );
      cms.add(
        new Sales_contact_metrics__c(
          Name = '2',
          Contact__c = con.Id,
          Month__c = date.newInstance(System.now().year(), 1, 1),
          KAH_HH_PPS_Admits__c = 2
        )
      );
      cms.add(
        new Sales_contact_metrics__c(
          Name = '3',
          Contact__c = con.Id,
          Month__c = date.newInstance(System.now().year(), 6, 15),
          KAH_HH_Admits__c = 1,
          KAH_HP_Admits__c = 1,
          KAH_HH_Referrals__c = 1,
          KAH_HP_Referrals__c = 1,
          KAH_HH_PPS_Admits__c = 1
        )
      );
      cms.add(
        new Sales_contact_metrics__c(
          Name = '4',
          Contact__c = con.Id,
          Month__c = date.newInstance(System.now().year(), 12, 31)
        )
      );
      insert cms;

      List<Event> events = new List<Event>();
      events.add(
        new Event(
          Subject = 'Test',
          OwnerId = objUser.Id,
          ActivityDate = date.today(),
          StartDateTime = System.Now(),
          EndDateTime = System.Now() + 5,
          Complete__c = true
        )
      );
      events.add(
        new Event(
          Subject = 'Test',
          OwnerId = objUser.Id,
          ActivityDate = date.today(),
          StartDateTime = System.Now(),
          EndDateTime = System.Now() + 5,
          Complete__c = true,
          WhatId = acct1.id
        )
      );
      events.add(
        new Event(
          Subject = 'Test',
          OwnerId = objUser.Id,
          ActivityDate = date.today(),
          StartDateTime = System.Now(),
          EndDateTime = System.Now() + 5,
          Complete__c = true,
          WhoId = con.id
        )
      );
      events.add(
        new Event(
          Subject = 'Test',
          OwnerId = objUser.Id,
          ActivityDate = date.today(),
          StartDateTime = System.Now(),
          EndDateTime = System.Now() + 5,
          Complete__c = true,
          WhatId = acct2.id
        )
      );
      insert events;
      List<Field_Coaching_Report__c> fcrs = new List<Field_Coaching_Report__c>();
      fcrs.add(new Field_Coaching_Report__c(createdById = objUser.Id));
      fcrs.add(
        new Field_Coaching_Report__c(createdById = UserInfo.getUserId())
      );
      insert fcrs;

      String json =
        '{' +
        '"usersAssignedAssignmentId" : "a1m6s000000T6YRAA0",' +
        '"title" : "Home Health Proficiency Evaluation",' +
        '"timeLimit" : null,' +
        '"subtitle" : null,' +
        '"questions" : [ {' +
        '"selectedAnswerList" : [ ],' +
        '"selectedAnswer" : "Codes associated with assessed patient characteristics, episode timing, and community vs institutional admission status",' +
        '"questionType" : "Multiple Choice",' +
        '"questionNumber" : 1,' +
        '"question" : "What is a Home Health Resources Group (HHRG)?",' +
        '"correct" : true,' +
        '"answers" : [ {' +
        '"value" : "An outside agency that tracks and scores a home health agencys patient satisfaction",' +
        '"label" : "An outside agency that tracks and scores a home health agencys patient satisfaction"' +
        '}, {' +
        ' "value" : "Aid provided to patients whose caregivers are no longer able to assist in their care",' +
        '"label" : "Aid provided to patients whose caregivers are no longer able to assist in their care"' +
        '}, {' +
        '"value" : "Codes associated with assessed patient characteristics, episode timing, and community vs institutional admission status",' +
        '"label" : "Codes associated with assessed patient characteristics, episode timing, and community vs institutional admission status"' +
        '}, {' +
        '"value" : "All of the above",' +
        '"label" : "All of the above"' +
        '} ],' +
        ' "answer" : "Codes associated with assessed patient characteristics, episode timing, and community vs institutional admission status"' +
        ' }' +
        '],' +
        '"percentage" : 5.71,' +
        ' "numberQuestions" : 35,' +
        '"numberCorrect" : 2,' +
        ' "name" : "Your",' +
        '"isTimed" : false,' +
        '"hasSubmitted" : true,' +
        '"description" : "This 35 question evaluation will assess your Home Health knowledge.",' +
        '"canViewQuiz" : true,' +
        '"assignmentId" : "a1k6s0000006m6JAAQ"' +
        ' }';
      Sales_Pro_2__c spp = new Sales_Pro_2__c(
        ownerId = objUser.Id,
        Training_Date__c = Date.newInstance(
          System.now().year(),
          System.now().month(),
          1
        )
      );
      insert spp;
      Assignment__c a = new Assignment__c(type__c = 'Quiz');
      insert a;
      Assigned_Assignment__c aa = new Assigned_Assignment__c(
        Sales_Pro_2__c = spp.Id,
        JSON__c = json,
        user__c = objUser2.Id,
        Assignment__c = a.Id
      );
      insert aa;
    }

  }

  public static Sales_LightningComponentCharts.filters getFilter() {
    Sales_LightningComponentCharts.filters myFilter = new Sales_LightningComponentCharts.filters();
    myFilter.dateString =
      String.valueOf(System.now().year()) +
      '-' +
      String.valueOf(System.now().month()) +
      '-' +
      '01';
    myFilter.region = 'Test';
    myFilter.area = 'Test';
    myFilter.market = 'Test';
    User u = [SELECT Id FROM user WHERE alias = 'tu' LIMIT 1];
    myFilter.user = u.Id;
    // return JSON.serialize(myFilter);
    return myFilter;
  }

  @IsTest
  static void getSalesPros() {
    Sales_LightningComponentCharts.filters filter = getFilter();
    User u = [SELECT Id FROM user WHERE alias = 'nuser' LIMIT 1];
    String region = 'Test';
    Sales_Pro_2__c sp = new Sales_Pro_2__c(ownerId = u.Id);
    insert sp;
    Test.startTest();
    Sales_SalesPro.getSalesPros(region, 'team');
    Sales_SalesPro.getSalesPros(region, 'mine');
    Sales_SalesPro.getSalesPros(region, 'all');
    Test.stopTest();
  }

  @IsTest
  static void fetchFiles() {
    ContentWorkspace cw = [
      SELECT id
      FROM contentWorkspace
      WHERE name = 'SalesPro Plus'
    ];
      system.debug('cw id'+cw.Id);

    ContentVersion cv = new ContentVersion();
    cv.Description = 'test description';
    cv.PathOnClient = 'test_file.txt';
    cv.Title = 'test file ' + DateTime.now();
    cv.versiondata = Blob.valueOf('test file body');
    insert cv;
       ContentVersion cv2 = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
      ];
      system.debug('cvs id'+cv2.ContentDocumentId);
      
    ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(
        ContentWorkspaceId = cw.Id,
        ContentDocumentId = cv2.ContentDocumentId

    );
    insert newWorkspaceDoc;

    Test.startTest();
    Sales_SalesPro.fetchFiles();
    Test.stopTest();
  }
  @IsTest
  static void getUserFilter() {
    Test.startTest();
    Sales_SalesPro.getUserFilter('region');
    Sales_SalesPro.getUserFilter('district');
    Sales_SalesPro.getUserFilter('area');
    Sales_SalesPro.getUserFilter('market');
    Test.stopTest();
  }
  @IsTest
  static void getAggregateQuiz() {
    Test.startTest();
    Sales_SalesPro.getAggregateQuiz('Test', 'mine', null);
    Sales_SalesPro.getAggregateQuiz('Test', 'team', null);
    Sales_SalesPro.getAggregateQuiz('Test', 'all', null);
    Test.stopTest();
  }
  @IsTest
  static void get6x6() {
    Test.startTest();
    Sales_SalesPro.getSixBySix('Test', 'mine', null);
    Sales_SalesPro.getSixBySix('Test', 'team', null);
    Sales_SalesPro.getSixBySix('Test', 'all', null);
    Test.stopTest();
  }
}*/