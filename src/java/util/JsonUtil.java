/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;

/**
 *
 * @author admin
 */
public class JsonUtil {
        private static final ObjectMapper mapper = new ObjectMapper();
    public static Map fromJson(String json, Class<Map> clazz) throws Exception {
        return mapper.readValue(json, clazz);
    }
}
