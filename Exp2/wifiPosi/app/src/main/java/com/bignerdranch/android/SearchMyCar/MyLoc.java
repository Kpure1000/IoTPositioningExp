package com.bignerdranch.android.beaconlocation;

import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class MyLoc extends AppCompatActivity {

    private List<BluetoothDevice> mBlueList = new ArrayList<>();
    private ListView lisetView;
    private TextView textView1;
    private RelativeLayout.LayoutParams params;
    private RelativeLayout relativeLayout;
    private ArrayList<ImageView> imageView = new ArrayList<ImageView>(){};
    private TextView mTextView;
    private Button mButton_ceshi;
    private final static int SEARCH_CODE = 0x123;
    private BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    private String MAC1 = "5C:03:39:BB:36:49";
    private String MAC2 = "A0:86:C6:1E:52:2E";
    private String MAC3 = "73:F1:94:03:22:B6";
    private int i = 0;
    private int aim_x = 0,aim_y = 0;
    private double mac1 = 0,mac2 = 0,mac13 = 0;
    private final int power = 45; //1m时信号强度
    private final double n = 3.5; //环境衰减因子


    //利用RSSI计算距离
    private double calDis(int rssi){
        int iRssi = Math.abs(rssi);
        double Power = (iRssi-power)/(10*n);
        return Math.pow(10,Power);
    }

    private void my_loc(){
        double a=p0_x-p2_x;
        double b=p0_y-p2_y;
        double c= Math.pow(p0_x, 2) - Math.pow(p2_x, 2) + Math.pow(p0_y, 2) - Math.pow(p2_y, 2) + Math.pow(mac3, 2) - Math.pow(mac1, 2);
        double d=p1_x-p2_x;
        double e=p1_y-p2_y;
        double f=Math.pow(p1_x, 2) - Math.pow(p2_x, 2) + Math.pow(p1_y, 2) - Math.pow(p2_y, 2) + Math.pow(mac3, 2) - Math.pow(mac2, 2);
        aim_x=(int)((b*f-e*c)/(2*b*d-2*a*e));
        aim_y=(int)((a*f-d*c)/(2*a*e-2*b*d));
        String string=String.valueOf(aim_x).substring(0,5)+","+String.valueOf(aim_y).substring(0,5);
    }
    Handler handler=new Handler();
    Runnable runnable=new Runnable() {
        @Override
        public void run() {
            startScanBluth();
            refresh();
            handler.postDelayed(this, 3000);
        }
    };
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_location);
        init();
        relativeLayout = findViewById(R.id.relative);
        mTextView = (TextView)findViewById(R.id.rotate);

        handler.postDelayed(runnable, 3000);
    }
     mButton_ceshi.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
                init();
            refresh();
        }
        });

    public void refresh(){
        my_loc();//调用算法计算相对位置
        imageView.add(i,new ImageView(MyLoc.this));
        imageView.get(i).setImageResource(R.drawable.photo);
        params = new RelativeLayout.LayoutParams(100,100);
        params.setMargins(aim_x,1500-aim_y/2, 0, 0);

        imageView.get(i).setLayoutParams(params);
        relativeLayout.addView(imageView.get(i));
        mTextView.setText("x="+aim_x+",y="+aim_y);
        Log.e("Locationxy",Integer.toString(aim_x)+"  "+Integer.toString(aim_y));//进行记录
        i++;
        }


