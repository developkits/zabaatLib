import QtTest 1.0
import QtQuick 2.0
import Zabaat.MVVM 1.0
import Zabaat.Utility 1.0
import Zabaat.Testing 1.0
ZabaatTest {
    id : rootObject
    objectName: "RestArrayCreator"
    testObj: Item{}

    QtObject {
        id : helpers
        function arrayIndexOf(arr,str,startIndex){
            startIndex = startIndex || 0
            for(var a = startIndex; a < arr.length; a++){
                var e = arr[a]
//                console.log("(",e, ")INDEX OF(", str, ")=" , e.indexOf(str))
                if(e.indexOf(str) !== -1)
                    return a;
            }
            return -1;
        }

        function arrEq(a,b, badRetFn){
            badRetFn = typeof badRetFn === 'function' ? badRetFn : function(a,b) { return false ; }

            if(!Lodash.isArray(a) || !Lodash.isArray(b))
                return false;

            if(a.length !== b.length){
                return badRetFn(a,b);
            }

            for(var i = 0; i < a.length; ++i){
                if(a[i] != b[i])
                    return badRetFn(a,b);
            }
            return true;
        }

        function arrayContains(arr, str, instances,print){
            var exact = true;
            if(!instances || typeof instances !== 'number') {
                instances = 1;
                exact = false;
            }

            instances = Math.max(instances,1);
            var s     = 0;
            var count = 0;
            while(exact || count < instances) {
                var idx = arrayIndexOf(arr,str,s)
                if(idx !== -1) {
                    s = idx+1;
                    count++;
                }
                else {
                    break;
                }
            }

            if(print)
                console.log("--->" , count + "/" + instances)

            return exact ? count === instances :
                           count >=  instances;

        }

        //returns true if all the before<signName> are before the <sigName> in the array
        //returns an error message if validation failed. Otherwise, returns true.
        function validateSignalOrder(arr){
            function firstToUpper(str){
                return str.charAt(0).toUpperCase() + str.slice(1);
            }

            for(var i in arr){
                var e = arr[i];
                if(e.indexOf('before'))
                    continue;

                var arrowIdx = e.indexOf('->');
                var varN     = e.slice(arrowIdx);
                var opName   = e.slice(0,arrowIdx);

                var idx = arrayContains(arr, 'before' + firstToUpper(opName));
                if(idx === -1)
                    return "No " + 'before' + firstToUpper(opName) + " for" + varN;
                if(idx > i)
                    return 'before' + firstToUpper(opName) + " for " + varN  + " is after the After!! "  + idx + ">" + i;
            }

            return true;
        }
    }



    function init(){

    }

    function cleanup(){
        RestArrayCreator.debugOptions.clearBatches();
    }

    function test_01_blankArray(){
        var arr = RestArrayCreator.create();
        compare(RestArrayCreator.debugOptions.batchBeforeCreateMsg.length, 0, "No properties were made!");
        compare(RestArrayCreator.debugOptions.batchCreateMsg.length      , 0, "No properties were made!");
        compare(RestArrayCreator.debugOptions.allCount()                 , 0);
    }

    function test_02_pushOne_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

//        console.log("@@@@@@")
//        console.log(allSigsStr)
//        console.log("@@@@@@")
        verify(helpers.arrayContains(allSignals,'beforeCreate->0'     ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->0/name') , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0'           ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0/name'      ) , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 4          , allSigsStr);

        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_03_pushTwo_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" }  , { id : 1, name : "Zabaat" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        verify(helpers.arrayContains(allSignals,'beforeCreate->0'      ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->0/name' ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0'            ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0/name'       ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->1'      ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->1/name' ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->1'            ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->1/name'       ) , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 8          , allSigsStr);

        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_04_pushExisting_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" }, { id : 0, name : "WolfyMania!!" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        verify(helpers.arrayContains(allSignals,'beforeCreate->0'      ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->0/name' ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0'            ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'create->0/name'       ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->0/name' ) , allSigsStr);
        verify(helpers.arrayContains(allSignals,'update->0/name'       ) , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 6, allSigsStr);


        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_05_splice_unIded(){
        var myFish = RestArrayCreator.create(['angel', 'clown', 'mandarin', 'surgeon']);

        function dispMsg(actual,expected){
            return "\nactual: ["  + actual + "]\nexpected: [" +  expected + "]\n";
        }

        // removes 0 elements from index 2, and inserts 'drum'
        var removed = myFish.splice(2, 0, 'drum');
        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removed is [], no elements removed
        var mRes = helpers.arrEq(myFish ,['angel', 'clown', 'drum', 'mandarin', 'surgeon'], dispMsg);
        var rRes = helpers.arrEq(removed,[] , dispMsg);

        verify(mRes === true, mRes);
        verify(rRes === true, rRes);


        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removes 1 element from index 3
        removed = myFish.splice(3, 1);
        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removed is ['mandarin']
        mRes = helpers.arrEq(myFish  , ['angel', 'clown', 'drum', 'surgeon'], dispMsg);
        rRes = helpers.arrEq(removed , ['mandarin'], dispMsg);
        verify(mRes === true, mRes);
        verify(rRes === true, rRes);

        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removes 1 element from index 2, and inserts 'trumpet'
        removed = myFish.splice(2, 1, 'trumpet');
        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removed is ['drum']
        mRes = helpers.arrEq(myFish     , ['angel', 'clown', 'trumpet', 'surgeon'], dispMsg);
        rRes = helpers.arrEq(removed    , ['drum'], dispMsg);
        verify(mRes === true, mRes);
        verify(rRes === true, rRes);

        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removes 2 elements from index 0, and inserts 'parrot', 'anemone' and 'blue'
        removed = myFish.splice(0, 2, 'parrot', 'anemone', 'blue');
        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removed is ['angel', 'clown']
        mRes = helpers.arrEq(myFish     , ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon'], dispMsg);
        rRes = helpers.arrEq(removed    , ['angel', 'clown'], dispMsg);
        verify(mRes === true, mRes);
        verify(rRes === true, rRes);

        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removes 2 elements from index 2
        removed = myFish.splice(myFish.length -3, 2);
        // myFish is ['parrot', 'anemone', 'surgeon']
        // removed is ['blue', 'trumpet']
        mRes = helpers.arrEq(myFish     ,['parrot', 'anemone', 'surgeon'], dispMsg);
        rRes = helpers.arrEq(removed    ,['blue', 'trumpet'], dispMsg);
        verify(mRes === true, mRes);
        verify(rRes === true, rRes);
    }

    function test_06_splice_unIded_signals(){
        var myFish = RestArrayCreator.create(['angel', 'clown', 'mandarin', 'surgeon']);

        //INSERT
        RestArrayCreator.debugOptions.clearBatches();   //cause we only want to test the signals from splice, not create.
        myFish.splice(2, 0, 'drum');    //myFish= ['angel', 'clown', 'drum', 'mandarin', 'surgeon']

        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        verify(helpers.arrayContains(allSignals,'beforeCreate->4 = "surgeon"'), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->2')            , allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->3')            , allSigsStr);
        verify(helpers.arrayContains(allSignals,'update->lenChanged')         , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount() , 7, allSigsStr);


        //REMOVE
        RestArrayCreator.debugOptions.clearBatches(); // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        myFish.splice(3, 1);    //myFish = ['angel', 'clown', 'drum', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = "\n" + allSignals.join('\n');

        verify(helpers.arrayContains(allSignals,'beforeDelete->4'   ), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->3'   ), allSigsStr);
        verify(helpers.arrayContains(allSignals,'update->lenChanged'), allSigsStr);

        compare(RestArrayCreator.debugOptions.allCount() , 5, allSigsStr);


        RestArrayCreator.debugOptions.clearBatches(); // myFish is ['angel', 'clown', 'drum', 'surgeon']
        myFish.splice(2, 1, 'trumpet');     //['angel', 'clown', 'trumpet', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = "\n" + allSignals.join('\n');

        //delete related updates
        verify(helpers.arrayContains(allSignals,'beforeUpdate->2'   ), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeDelete->3'   ), allSigsStr);

        //insert related updates
        verify(helpers.arrayContains(allSignals,'beforeCreate->3'   ), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->2'   ), allSigsStr);

        verify(helpers.arrayContains(allSignals,'update->lenChanged',2), allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount() , 10, allSigsStr);


        RestArrayCreator.debugOptions.clearBatches();
        myFish.splice(0, 2, 'parrot', 'amy', 'blue');   //['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = " \n" + allSignals.join(' \n');


        //Delete
        verify(helpers.arrayContains(allSignals,'beforeUpdate->0' ,5), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->1' ,5), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->2' ,3), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeUpdate->3' ,1), allSigsStr);

        verify(helpers.arrayContains(allSignals,'beforeDelete->2' ,1), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeDelete->3' ,1), allSigsStr);

        verify(helpers.arrayContains(allSignals,'beforeCreate->2' ,1), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->3' ,1), allSigsStr);
        verify(helpers.arrayContains(allSignals,'beforeCreate->4' ,1 ), allSigsStr);
        verify(helpers.arrayContains(allSignals,'update->lenChanged', 5));
        compare(RestArrayCreator.debugOptions.allCount(), 43);


        RestArrayCreator.debugOptions.clearBatches();

        myFish.splice(myFish.length -3, 2); //['parrot', 'anemone', 'surgeon']
        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = " \n" + allSignals.join(' \n');

//        RestArrayCreator.debugOptions.printAll();

        verify(helpers.arrayContains(allSignals,'beforeUpdate->2' ,2));
        verify(helpers.arrayContains(allSignals,'beforeUpdate->3' ,1));
        verify(helpers.arrayContains(allSignals,'beforeDelete->3' ,1));
        verify(helpers.arrayContains(allSignals,'beforeDelete->4' ,1));
        verify(helpers.arrayContains(allSignals,'update->lenChanged', 2));

        compare(RestArrayCreator.debugOptions.allCount(), 12);
    }




}
