---
title: JavaFX中多任务Task、Service、ScheduledService的使用
date: 2019/08/01 22:00:00
tags: 
- java
- JavaFX
category: 
- Technology
- JAVA
description: 文中以一个文件下载作为案例介绍，看代码即可明了
---

### 案例分析
> 文中以一个文件下载作为案例介绍，看代码即可明了
---
- Task
```
package com.hc.demo;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * @author stone
 */

public class MyApp extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        primaryStage.setTitle("Hello World!");

        HBox hBox=new HBox(10);

        Button startBtn = new Button("开始");
        Button cancelBtn = new Button("取消");
        Button resetBtn = new Button("重置");
        Button restartBtn = new Button("重启");
        ProgressBar progressBar = new ProgressBar(0);
        progressBar.setPrefWidth(200);

        Label l1=new Label("state");
        Label l2=new Label("value");
        Label l3=new Label("title");
        Label l4=new Label("message");

        FlowPane root = new FlowPane();
        hBox.getChildren().addAll(startBtn,cancelBtn,resetBtn,restartBtn,progressBar,l1,l2,l3,l4);
        root.getChildren().add(hBox);
        primaryStage.setScene(new Scene(root, 700, 300));
        primaryStage.show();

        MyTask myTask=new MyTask();
        Thread thread=new Thread(myTask);

        startBtn.setOnAction(event -> thread.start());
        cancelBtn.setOnAction(event ->
            myTask.cancel()
        );

        myTask.progressProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                progressBar.setProgress(newValue.doubleValue());
            }
        });

        myTask.titleProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                l3.setText(newValue);
            }
        });

        myTask.valueProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                if(newValue.doubleValue()==1){
                    l2.setText("完成");
                }
            }
        });

        myTask.messageProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                l4.setText(newValue);
            }
        });

        //wordkDone指的是进度
        myTask.stateProperty().addListener(new ChangeListener<Worker.State>() {
            @Override
            public void changed(ObservableValue<? extends Worker.State> observable, Worker.State oldValue, Worker.State newValue) {
                l1.setText(newValue.toString());
            }
        });

        //异常监听 监听现在状态是否有异常并打印
        myTask.exceptionProperty().addListener(new ChangeListener<Throwable>() {
            @Override
            public void changed(ObservableValue<? extends Throwable> observable, Throwable oldValue, Throwable newValue) {
                System.out.println(newValue);
            }
        });

    }

    public static void main(String[] args) {
        launch(args);
    }
}

class MyTask extends Task<Number>
{

    public MyTask() {
        super();
    }

    @Override
    protected Number call() throws Exception {

        this.updateTitle("copy");
        FileInputStream fis=new FileInputStream(new File("C:\\Users\\nrgh\\Desktop\\区块链\\porep时空证明.pdf"));
        FileOutputStream fos=new FileOutputStream(new File("C:\\Users\\nrgh\\Desktop\\区块链\\1.pdf"));
        //获取字节长
        double max=fis.available();
        byte[] readbyte=new byte[10000];
        int i=0;
        //目前完成进度
        double sum=0;
        //进度
        double progress=0;
        while((i=fis.read(readbyte,0,readbyte.length))!=-1){


            /*if (this.isCancelled()){
                break;
            }*/
            fos.write(readbyte,0,i);
            sum=sum+i;
            //当前和总共
            this.updateProgress(sum,max);
            progress=sum/max;
            System.out.println(progress);
            Thread.sleep(50);
            if (progress<0.5){
                this.updateMessage("请耐心等待");
            }else if (progress<0.8){
                this.updateMessage("马上就好");
            }else if (progress<1){
                this.updateMessage("即将完成");
            }else if (progress>=1){
                this.updateMessage("搞定了");
            }
        }

        fis.close();
        fos.close();
        System.out.println(Platform.isFxApplicationThread());
        return progress;
    }
}
```
- Service
```
package com.hc.demo;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.concurrent.Service;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * @author stone
 */

public class MyApp extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        primaryStage.setTitle("Hello World!");

        HBox hBox=new HBox(20);

        Button startBtn = new Button("开始");
        Button cancelBtn = new Button("取消");
        Button resetBtn = new Button("重置");
        Button restartBtn = new Button("重启");
        ProgressBar progressBar = new ProgressBar(0);
        progressBar.setPrefWidth(200);

        Label l1=new Label("state");
        Label l2=new Label("value");
        Label l3=new Label("title");
        Label l4=new Label("message");

        FlowPane root = new FlowPane();
        hBox.getChildren().addAll(startBtn,cancelBtn,restartBtn,resetBtn,progressBar,l1,l2,l3,l4);
        root.getChildren().add(hBox);
        primaryStage.setScene(new Scene(root, 700, 300));
        primaryStage.show();

        MyService ms=new MyService();

        startBtn.setOnAction(event ->
            ms.start()
        );
        cancelBtn.setOnAction(event ->
            ms.cancel()
        );
        resetBtn.setOnAction(event -> {
            ms.reset();
            progressBar.setProgress(0);
        });
        restartBtn.setOnAction(event -> {
            ms.restart();
        });


        ms.progressProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                progressBar.setProgress(newValue.doubleValue());
            }
        });

        ms.titleProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                l3.setText(newValue);
            }
        });

        ms.valueProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                if(newValue.doubleValue()==1){
                    l2.setText("完成");
                }
            }
        });

        ms.messageProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {
                l4.setText(newValue);
            }
        });

        //wordkDone指的是进度
        ms.stateProperty().addListener(new ChangeListener<Worker.State>() {
            @Override
            public void changed(ObservableValue<? extends Worker.State> observable, Worker.State oldValue, Worker.State newValue) {
                l1.setText(newValue.toString());
            }
        });

        //异常监听 监听现在状态是否有异常并打印
        ms.exceptionProperty().addListener(new ChangeListener<Throwable>() {
            @Override
            public void changed(ObservableValue<? extends Throwable> observable, Throwable oldValue, Throwable newValue) {
                System.out.println(newValue);
            }
        });

    }

    public static void main(String[] args) {
        launch(args);
    }
}


class MyService extends Service<Number>
{

    @Override
    protected void executeTask(Task<Number> task) {
        super.executeTask(task);
        task.valueProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                System.out.println("executeTask valueProperty");
            }
        });
    }

    @Override
    protected void ready() {
        super.ready();
        System.out.println("ready"+Platform.isFxApplicationThread());
    }

    @Override
    protected void scheduled() {
        super.scheduled();
        System.out.println("scheduled "+Platform.isFxApplicationThread());
    }

    @Override
    protected void running() {
        super.running();
        System.out.println("running "+Platform.isFxApplicationThread());
    }

    @Override
    protected void succeeded() {
        super.succeeded();
        System.out.println("succeeded "+Platform.isFxApplicationThread());
    }

    @Override
    protected void cancelled() {
        super.cancelled();
        System.out.println("cancelled "+Platform.isFxApplicationThread());
    }

    @Override
    protected void failed() {
        super.failed();
        System.out.println("failed "+Platform.isFxApplicationThread());
    }

    @Override
    protected Task<Number> createTask() {

        Task<Number> task=new Task<Number>() {
            @Override
            protected Number call() throws Exception {

                this.updateTitle("copy");
                FileInputStream fis=new FileInputStream(new File("C:\\Users\\nrgh\\Desktop\\区块链\\porep时空证明.pdf"));
                FileOutputStream fos=new FileOutputStream(new File("C:\\Users\\nrgh\\Desktop\\区块链\\1.pdf"));
                //获取字节长
                double max=fis.available();
                byte[] readbyte=new byte[10000];
                int i=0;
                //目前完成进度
                double sum=0;
                //进度
                double progress=0;
                while((i=fis.read(readbyte,0,readbyte.length))!=-1){

                    /*if (this.isCancelled()){
                        break;
                    }*/
                    fos.write(readbyte,0,i);
                    sum=sum+i;
                    //当前大小和总共大小
                    this.updateProgress(sum,max);
                    progress=sum/max;
                    /*System.out.println(progress);*/
                    Thread.sleep(50);
                    if (progress<0.5){
                        this.updateMessage("请耐心等待");
                    }else if (progress<0.8){
                        this.updateMessage("马上就好");
                    }else if (progress<1){
                        this.updateMessage("即将完成");
                    }else if (progress>=1){
                        this.updateMessage("搞定了");
                    }
                }

                fis.close();
                fos.close();
                System.out.println(Platform.isFxApplicationThread());
                return progress;
            }
        };
        return task;
    }
}
```
- ScheduledService
```
package com.hc.demo;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.concurrent.ScheduledService;
import javafx.concurrent.Service;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import javafx.util.Duration;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * @author stone
 */

public class MyApp extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        primaryStage.setTitle("Hello World!");

        HBox hBox=new HBox(20);

        Button startBtn = new Button("开始");
        Button cancelBtn = new Button("取消");
        Button resetBtn = new Button("重置");
        Button restartBtn = new Button("重启");
        ProgressBar progressBar = new ProgressBar(0);
        progressBar.setPrefWidth(200);

        Label l1=new Label("state");
        Label l2=new Label("value");
        Label l3=new Label("title");
        Label l4=new Label("message");

        FlowPane root = new FlowPane();
        hBox.getChildren().addAll(startBtn,cancelBtn,restartBtn,resetBtn,progressBar,l1,l2,l3,l4);
        root.getChildren().add(hBox);
        primaryStage.setScene(new Scene(root, 700, 300));
        primaryStage.show();

        MyScheduledService mss=new MyScheduledService();
        //等待5s开始、



        mss.setDelay(Duration.seconds(5));
        //程序执行时间
        mss.setPeriod(Duration.seconds(1));
        //启动失败重新启动
        mss.setRestartOnFailure(true);
        //程序启动失败后重新启动次数
        mss.setMaximumFailureCount(4);

        startBtn.setOnAction(event ->{
            mss.start();
            System.out.println("开始");
        });
        cancelBtn.setOnAction(event ->{
            mss.cancel();
            System.out.println("取消");
        });
        resetBtn.setOnAction(event -> {
            mss.reset();
            System.out.println("重置");
        });
        restartBtn.setOnAction(event -> {
            mss.restart();
            System.out.println("重启");
        });

        mss.valueProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                if (newValue!=null){
                    l2.setText(String.valueOf(newValue));
                }
            }
        });

        mss.lastValueProperty().addListener(new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
                if (newValue!=null){
                    System.out.println("lastValue="+newValue.intValue());
                }
            }
        });

    }

    public static void main(String[] args) {
        launch(args);
    }
}

class MyScheduledService extends ScheduledService<Number>{

    int sum=0;
    @Override
    protected Task<Number> createTask() {

        System.out.println("createTask()");

        Task<Number> task=new Task<Number>() {

            @Override
            protected void updateValue(Number value) {
                super.updateValue(value);
                if (value.intValue()==10){
                    MyScheduledService.this.cancel();
                    System.out.println("任务取消");
                }
            }

            @Override
            protected Number call() throws Exception {
                sum=sum+1;
                System.out.println(sum);
                return sum;
            }
        };
        return task;
    }
}
```
### 参考文档
---
[https://wiki.openjdk.java.net/display/OpenJFX/Main](https://wiki.openjdk.java.net/display/OpenJFX/Main)

[https://openjfx.io/javadoc/11/](https://openjfx.io/javadoc/11/)

https://openjfx.io/javadoc/11/javafx.graphics/javafx/concurrent/package-summary.html