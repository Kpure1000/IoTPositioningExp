package cn.edu.xjtlu.eee.wifiscanner;
import android.app.Activity;
import android.content.Context;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;


public class MainActivity extends Activity {
	private TextView wifiText;
	private WifiManager wifiManager;
	private List<ScanResult> wifiList;
	private Set<String> totalAPs = new HashSet();
	private Point point;
	private Point nearestPoint;
	private ArrayList<Point> totalPoints = new ArrayList();
	Map<String, Integer> minLevel = new HashMap();
	private Point tempPoint;
	int maxSize = 0;
	double minDistance;
	double[] distance;
	int mini;
	private Button start;
	private Button calculate;
	private EditText X;
	private EditText Y;
	private TextView END;
	//private EditText times;
	//private EditText interval;
	private EditText fileNamEditText;
	public Handler handler =   new Handler() {
		public void handleMessage(Message msg) {
			if (msg.what == 291) {

				if (count != timesValue) {
					wifiList = wifiManager.getScanResults();


					if (maxSize < wifiList.size()) {
						tempPoint.aps.clear();
						maxSize = wifiList.size();
						info = info + String.valueOf(count) + "\n";

						for(int i = 0; i <wifiList.size(); ++i) {
							String SSID = null;
							AP ap = new AP();
							SSID = wifiList.get(i).SSID;//((ScanResult)MainActivity.this.wifiList.get(i)).SSID;
							if (totalAPs.contains(SSID)) {
								if (minLevel.get(SSID) > wifiList.get(i).level) {
									minLevel.put(SSID, wifiList.get(i).level);
								}
							} else {
								totalAPs.add(SSID);
								minLevel.put(SSID, wifiList.get(i).level);//放入最新的SSID
							}

							ap.SSID = SSID;
							ap.level = wifiList.get(i).level;
							tempPoint.aps.add(ap);

							info = info + "BSSID:" + wifiList.get(i).BSSID + "  level:" + wifiList.get(i).level + " " + "frequency" + wifiList.get(i).frequency + "\n";
						}


						info = info + "\n";
					} else {

						info = info + String.valueOf(MainActivity.this.count) + "\n";

						for(int i = 0; i < wifiList.size(); ++i) {
							String SSID = null;
							SSID = wifiList.get(i).SSID;
							totalAPs.add(SSID);

							info = info + "BSSID:" + wifiList.get(i).BSSID + "  level:" + wifiList.get(i).level + " " + "frequency" + wifiList.get(i).frequency + "\n";
						}

						info = info + "\n";
					}
				} else {
					timer.cancel();
					X.getText().clear();
					Y.getText().clear();
					//MainActivity.this.times.getText().clear();
					//MainActivity.this.interval.getText().clear();
					count = 0;
					info = info + "\n";
					writeToFile(fileName, info);
					MainActivity.this.info = "";
					Toast.makeText(MainActivity.this, "扫描完成！", 9000).show();

				}
			}

		}
	};
	private int count = 0;

	private int APcount;
	private int timesValue;
	public String fileName;
	PrintStream ps;
	String info = "";
	String path = "";
	Timer timer;



	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_main);
		this.X = (EditText)findViewById(R.id.x);
		this.Y = (EditText)findViewById(R.id.y);
		//END=(TextView)findViewById(R.id.end);
		//this.times = (EditText)this.findViewById(R.id.times);
		fileNamEditText = (EditText)findViewById(R.id.fileName);
		//this.interval = (EditText)this.findViewById(R.id.interval);
		wifiText = (TextView)findViewById(R.id.wifi);
		wifiManager = (WifiManager)getSystemService("wifi");
		start = (Button)findViewById(R.id.start);
		calculate = (Button)findViewById(R.id.cal);
		/*END.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				String temp = END.getText().toString();

				if(temp.equals("此处为参考点(点击此处切换)")){

					END.setText("此处为待定位点(点击此处切换)");
				} else {

					END.setText("此处为参考点(点击此处切换)");
				}
			}
		});*/
		this.start.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				timesValue = 3;//Integer.parseInt(MainActivity.this.times.getText().toString()) + 1;
				tempPoint = new Point();
				tempPoint.aps.clear();
				tempPoint.x = -1;
				tempPoint.y = -1;
				tempPoint.x = Integer.valueOf(X.getText().toString());
				tempPoint.y = Integer.valueOf(Y.getText().toString());


				maxSize = 0;
				timer = new Timer();
				APcount = 0;
				fileName = fileNamEditText.getText().toString();
				wifiManager.startScan();
				wifiText.setText("\nStarting Scan...\n");
				info = info + (new Date()).toLocaleString();
 				info = info + " X= " + X.getText().toString() + " Y= " + Y.getText().toString() + "/n";
				//" 次数：" + MainActivity.this.times.getText().toString() + " 间隔：" + MainActivity.this.interval.getText().toString() + "ms\n";
				timer.schedule(new TimerTask() {
					@Override
					public void run() {
						handler.sendEmptyMessage(291);
						int retime=2-count;
						wifiText.setText("扫描剩余时间:"+retime+"s");
						if(retime<0){wifiText.setText("该节点扫描完成");}
						count = count + 1;
						System.out.println(count);
					}
				}, 0, (long)1000);//Integer.parseInt(MainActivity.this.interval.getText().toString())
				totalPoints.add(tempPoint);
			}
		});


		calculate.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {

				//-------------------------------------------------------------------------------------

					nearestPoint = calculate();
					StringBuilder sBuilder = new StringBuilder();

					int i;

					int j;
					for(i = 0; i < MainActivity.this.totalPoints.size() - 1; ++i) {
						sBuilder.append("\n");
						sBuilder.append("参考点" + (i + 1) + "坐标 (" + totalPoints.get(i).x + "," +totalPoints.get(i).y + ")\n");
						ArrayList<AP> aps = totalPoints.get(i).aps;

						//    for(j = 0; j < aps.size(); ++j) {
						//       sBuilder.append(((AP)aps.get(j)).SSID + " " + ((AP)aps.get(j)).level + "\n");
						//       }

						sBuilder.append("The distance is:" + distance[i] + "\n\n");
					}

					//sBuilder.append("The measure point: X= " + ((Point)MainActivity.this.totalPoints.get(i)).x + " Y= " + ((Point)MainActivity.this.totalPoints.get(i)).y + "\n");
				    ArrayList<AP> aps = totalPoints.get(i).aps;

					//for(j = 0; j < aps.size(); ++j) {
						//sBuilder.append(((AP)aps.get(j)).SSID + " " + ((AP)aps.get(j)).level + "\n");
					//}

					sBuilder.append("\nThe nearest point is :Point " + (mini + 1) + "\n distance:" + minDistance);
					wifiText.setText(sBuilder.toString());


			}
		});
	}

	private Point calculate() {
		minDistance = Double.MAX_VALUE;//1.7976931348623157E308D;
		mini = -1;
		distance = new double[totalPoints.size() - 1];
		Point endPoint = totalPoints.get(totalPoints.size() - 1);

		for(int i = 0; i < totalPoints.size() - 1; ++i) {
			double tempDistance = calculate_Distance(endPoint, totalPoints.get(i));
			distance[i] = tempDistance;
			if (tempDistance < minDistance) {
				minDistance = tempDistance;
				mini = i;
			}
		}

		return totalPoints.get(mini);
	}

	private double calculate_Distance(Point point1, Point point2) {
		float result = 1.3F;
		Map<String, Integer> tempMap1 = new HashMap<String, Integer>();
		Map<String, Integer> tempMap2 = new HashMap<String, Integer>();

		for(int j = 0; j < point2.aps.size(); ++j) {
			tempMap2.put(point2.aps.get(j).SSID, point2.aps.get(j).level);
		}

		for(int i = 0; i < point1.aps.size(); ++i) {
			tempMap1.put(point1.aps.get(i).SSID, point1.aps.get(i).level);
		}

		Iterator iterator = totalAPs.iterator();

		while(iterator.hasNext()) {
			String str = (String)iterator.next();
			if (tempMap1.containsKey(str) && tempMap2.containsKey(str)) {
				result += (tempMap1.get(str) - tempMap2.get(str)) * (tempMap1.get(str) - tempMap2.get(str));
			}

			if (tempMap1.containsKey(str) && !tempMap2.containsKey(str)) {
				result += (tempMap1.get(str) - minLevel.get(str)) * (tempMap1.get(str) - minLevel.get(str));
			}

			if (!tempMap1.containsKey(str) && tempMap2.containsKey(str)) {
				result += (tempMap2.get(str) - minLevel.get(str)) * (tempMap2.get(str) - minLevel.get(str));
			}
		}

		return Math.sqrt(result);
	}

	private void writeToFile(String fileName, String content) {
		try {
			File file = new File("/mnt/sdcard", fileName);
			if (!file.exists()) {
				file.createNewFile();
			}

			OutputStream out = new FileOutputStream(file, true);
			out.write(content.getBytes());
			out.close();
		} catch (Exception var5) {
			var5.printStackTrace();
		}

	}

	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(0, 0, 0, "刷新");
		return super.onCreateOptionsMenu(menu);
	}

	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		wifiManager.startScan();
		wifiText.setText("已刷新");
		return super.onMenuItemSelected(featureId, item);
	}
}